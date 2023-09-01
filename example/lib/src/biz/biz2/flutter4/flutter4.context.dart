// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

part of 'flutter4.page.dart';

extension Flutter4Context on ModuleContext {
  /// get a people.
  ///
  People get people =>
      get<People>('people') ?? (throw ArgumentError('people cannot be null'));

  bool setPeople(final People value) => set<People>('people', value);

  /// remove a people.
  ///
  People? removePeople() => remove<People>('people');

  Stream<People?> get onPeople =>
      on<People>('people') ??
      (throw ArgumentError('people stream cannot be null'));
}
