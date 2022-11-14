// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../extension/thrio_iterable.dart';
import '../module/module_anchor.dart';
import '../module/module_types.dart';
import '../module/thrio_module.dart';
import 'navigator_logger.dart';
import 'navigator_observer_manager.dart';
import 'navigator_page_observer_channel.dart';
import 'navigator_page_route.dart';
import 'navigator_route_observer_channel.dart';
import 'navigator_route_receive_channel.dart';
import 'navigator_route_send_channel.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

class ThrioNavigatorImplement {
  factory ThrioNavigatorImplement.shared() => _default;

  ThrioNavigatorImplement._();

  static final ThrioNavigatorImplement _default = ThrioNavigatorImplement._();

  void init(final ModuleContext moduleContext) {
    _channel = ThrioChannel(channel: '__thrio_app__${moduleContext.entrypoint}');
    ThrioChannel(channel: '__thrio_module_context__${moduleContext.entrypoint}')
        .registryMethodCall('set', ([final arguments]) async {
      if (arguments == null || arguments.isEmpty) {
        return;
      }
      for (final key in arguments.keys) {
        final value = arguments[key];
        if (value == null) {
          anchor.remove<dynamic>(key);
        } else {
          anchor.set(key, _deserializeParams(value));
        }
      }
    });
    _sendChannel = NavigatorRouteSendChannel(_channel);
    _receiveChannel = NavigatorRouteReceiveChannel(_channel);
    pageChannel = NavigatorPageObserverChannel(moduleContext.entrypoint);
    routeChannel = NavigatorRouteObserverChannel(moduleContext.entrypoint);
    _observerManager = NavigatorObserverManager();
    _stateKey = GlobalKey<NavigatorWidgetState>();
    _moduleContext = moduleContext;

    verbose('TransitionBuilder init');
  }

  TransitionBuilder get builder => (final context, final child) {
        if (child is Navigator) {
          final navigator = child;
          if (!navigator.observers.contains(_observerManager)) {
            navigator.observers.add(_observerManager);
          }
          return NavigatorWidget(
            key: _stateKey,
            moduleContext: _moduleContext,
            observerManager: _observerManager,
            child: navigator,
          );
        }
        return const SizedBox(
          width: 200,
          height: 100,
          child: Text('child for builder must be Navigator'),
        );
      };

  late final ModuleContext _moduleContext;

  late final GlobalKey<NavigatorWidgetState> _stateKey;

  NavigatorWidgetState? get navigatorState => _stateKey.currentState;

  final poppedResults = <String, NavigatorParamsCallback>{};

  late final ThrioChannel _channel;

  late final NavigatorRouteSendChannel _sendChannel;

  late final NavigatorRouteReceiveChannel _receiveChannel;

  late final NavigatorRouteObserverChannel routeChannel;

  late final NavigatorPageObserverChannel pageChannel;

  late final NavigatorObserverManager _observerManager;

  void ready() => _channel.invokeMethod<bool>('ready');

  Future<int> push<TParams>({
    required final String url,
    final TParams? params,
    final bool animated = true,
    final NavigatorParamsCallback? poppedResult,
  }) =>
      _sendChannel
          .push<TParams>(url: url, params: params, animated: animated)
          .then<int>((final index) {
        if (poppedResult != null && index > 0) {
          final routeName = '$index $url';
          final routeHistory = ThrioNavigatorImplement.shared().navigatorState?.history;
          final route = routeHistory?.lastWhereOrNull((final it) => it.settings.name == routeName);
          if (route != null && route is NavigatorPageRoute) {
            route.poppedResult = poppedResult;
          } else {
            // 不在当前页面栈上，则通过name来缓存
            poppedResults[routeName] = poppedResult;
          }
        }
        return index;
      });

  Future<bool> notify<TParams>({
    final String? url,
    final int index = 0,
    required final String name,
    final TParams? params,
  }) =>
      _sendChannel.notify<TParams>(name: name, url: url, index: index, params: params);

  Future<bool> pop<TParams>({
    final TParams? params,
    final bool animated = true,
  }) =>
      _sendChannel.pop<TParams>(params: params, animated: animated);

  Future<bool> popTo({
    required final String url,
    final int index = 0,
    final bool animated = true,
  }) =>
      _sendChannel.popTo(url: url, index: index, animated: animated);

  Future<bool> remove({
    required final String url,
    final int index = 0,
    final bool animated = true,
  }) =>
      _sendChannel.remove(url: url, index: index, animated: animated);

  Future<int> removeAll({required final String url, final int excludeIndex = 0}) async {
    var total = 0;
    var isMatch = false;
    final all = (await allRoutes(url: url)).skipWhile((final it) => it.index == excludeIndex);
    for (final r in all) {
      if (r.url == null) {
        continue;
      }
      isMatch = await _sendChannel.remove(url: r.url!, index: r.index);
      if (isMatch) {
        total += 1;
      }
    }
    return total;
  }

  Future<int> replace({
    required final String url,
    final int index = 0,
    required final String newUrl,
    final bool replaceOnly = false,
  }) =>
      _sendChannel.replace(url: url, index: index, newUrl: newUrl, replaceOnly: replaceOnly);

  Future<bool> isInitialRoute({required final String url, final int index = 0}) =>
      _sendChannel.isInitialRoute(url: url, index: index);

  Future<RouteSettings?> lastRoute({final String? url}) => _sendChannel.lastRoute(url: url);

  Future<List<RouteSettings>> allRoutes({final String? url}) => _sendChannel.allRoutes(url: url);

  RouteSettings? lastFlutterRoute({final String? url}) {
    if (url == null || url.isEmpty) {
      return navigatorState?.history.lastOrNull?.settings;
    }
    return navigatorState?.history
        .lastWhereOrNull((final it) => it is NavigatorPageRoute && it.settings.url == url)
        ?.settings;
  }

  List<RouteSettings> allFlutterRoutes({final String? url}) {
    if (url == null || url.isEmpty) {
      return navigatorState?.history
              .whereType<NavigatorPageRoute>()
              .map<RouteSettings>((final it) => it.settings)
              .toList() ??
          <RouteSettings>[];
    }
    return navigatorState?.history
            .where((final it) => it is NavigatorPageRoute && it.settings.url == url)
            .map((final it) => it.settings)
            .toList() ??
        <RouteSettings>[];
  }

  bool isContainsInnerRoute({required final String url}) {
    final routes = navigatorState?.history ?? <NavigatorPageRoute>[];
    final index = url.isEmpty
        ? routes.lastIndexWhere((final route) => route is NavigatorPageRoute)
        : routes.lastIndexWhere(
            (final route) => route is NavigatorPageRoute && route.settings.url == url);
    if (index < 0 || routes.length <= index + 1) {
      return false;
    }
    return routes[index + 1] is! NavigatorPageRoute;
  }

  Future<bool> setPopDisabled({
    required final String url,
    final int index = 0,
    final bool disabled = true,
  }) =>
      _sendChannel.setPopDisabled(url: url, index: index, disabled: disabled);

  Stream<dynamic> onPageNotify({
    required final String name,
    final String? url,
    final int index = 0,
  }) =>
      _receiveChannel.onPageNotify(name: name, url: url, index: index);

  void hotRestart() {
    _channel.invokeMethod<bool>('hotRestart');
  }

  dynamic _deserializeParams(final dynamic params) {
    if (params == null) {
      return null;
    }

    if (params is Map && params.containsKey('__thrio_TParams__')) {
      // ignore: avoid_as
      final typeString = params['__thrio_TParams__'] as String;
      if (typeString.isNotEmpty) {
        final paramsObj = ThrioModule.get<JsonDeserializer<dynamic>>(key: typeString)
            ?.call(params.cast<String, dynamic>());
        if (paramsObj != null) {
          return paramsObj;
        }
      }
    }

    return params;
  }
}
