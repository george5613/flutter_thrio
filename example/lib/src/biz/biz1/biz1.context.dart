// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

extension Biz1Context on ModuleContext {
  /// get an int value.
  ///
  int get intValue =>
      get<int>('intValue') ?? (throw ArgumentError('intValue cannot be null'));

  bool setIntValue(final int value) => set<int>('intValue', value);

  /// remove an int value.remove an int value.remove an int value.
  ///
  int? removeIntValue() => remove<int>('intValue');

  Stream<int?> get onIntValue =>
      on<int>('intValue') ??
      (throw ArgumentError('intValue stream cannot be null'));
}
