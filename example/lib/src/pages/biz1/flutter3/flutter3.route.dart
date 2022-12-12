// Copyright (c) 2022 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

class Flutter3Route extends NavigatorRouteLeaf {
  factory Flutter3Route(final NavigatorRouteNode parent) => _instance ??= Flutter3Route._(parent);

  Flutter3Route._(super.parent);

  static Flutter3Route? _instance;

  @override
  String get name => 'flutter3';

  Future<TPopParams?> push<TParams, TPopParams>({
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigator.push<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
      );
}
