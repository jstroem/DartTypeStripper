// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of pop_pop_win.game;

class GameState {
  static const reset = const GameState._internal("reset");
  static const started = const GameState._internal("started");
  static const won = const GameState._internal("won");
  static const lost = const GameState._internal("lost");
  final name;

  const GameState._internal(this.name);

  toString() => 'GameState: $name';
}

