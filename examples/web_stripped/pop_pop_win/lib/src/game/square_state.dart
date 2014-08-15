// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of pop_pop_win.game;

class SquareState {
  static const hidden = const SquareState._internal("hidden");
  static const revealed = const SquareState._internal("revealed");
  static const flagged = const SquareState._internal("flagged");
  static const bomb = const SquareState._internal("bomb");
  static const safe = const SquareState._internal('safe');
  final name;

  const SquareState._internal(this.name);

  toString() => 'SquareState: $name';
}

