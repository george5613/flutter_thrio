// Copyright (c) 2022 bybit.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

import '../../types/people.dart';

class Flutter4Route extends NavigatorRouteLeaf {
  factory Flutter4Route(final NavigatorRouteNode parent) =>
      _instance ??= Flutter4Route._(parent);

  Flutter4Route._(final super.parent);

  static Flutter4Route? _instance;

  @override
  String get name => 'flutter4';

  /// 打开 people 页面
  ///
  Future<int> push(
    final People people, {
    final bool animated = true,
    final NavigatorParamsCallback? poppedResult,
  }) =>
      ThrioNavigator.push<People>(
        url: url,
        params: people,
        animated: animated,
        poppedResult: poppedResult,
      );
}
