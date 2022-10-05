// Copyright (c) 2022 bybit.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

class HomeRoute extends NavigatorRouteLeaf {
  factory HomeRoute(final NavigatorRouteNode parent) =>
      _instance ??= HomeRoute._(parent);

  HomeRoute._(final super.parent);

  static HomeRoute? _instance;

  @override
  String get name => 'home';

  Future<int> push<TParams>({
    final TParams? params,
    final bool animated = true,
    final NavigatorParamsCallback? poppedResult,
  }) =>
      ThrioNavigator.push(
        url: url,
        params: params,
        animated: animated,
        poppedResult: poppedResult,
      );
}
