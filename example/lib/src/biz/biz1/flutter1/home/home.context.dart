// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

part of 'home.page.dart';

extension HomeContext on ModuleContext {
  String get stringKeyBiz1 =>
      get<String>('stringKeyBiz1') ??
      (throw ArgumentError('stringKeyBiz1 cannot be null'));

  bool setStringKeyBiz1(final String value) =>
      set<String>('stringKeyBiz1', value);

  Stream<String?> get onStringKeyBiz1 =>
      on<String>('stringKeyBiz1') ??
      (throw ArgumentError('stringKeyBiz1 stream cannot be null'));

  int get intKeyRootModule =>
      get<int>('intKeyRootModule') ??
      (throw ArgumentError('intKeyRootModule cannot be null'));

  bool setIntKeyRootModule(final int value) =>
      set<int>('intKeyRootModule', value);
}
