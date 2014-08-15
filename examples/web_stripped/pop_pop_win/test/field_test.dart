// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.field_test;

import 'package:pop_pop_win/src/game.dart';
import 'package:unittest/unittest.dart';

import 'test_util.dart';

main() {
  test('defaults', _testDefaults);
  test('bombCount', _testBombCount);
  test('fromSquares', _testFromSquares);
  test('adjacent', _testAdjacent);
}

_testDefaults() {
  var f = new Field();

  expect(f.bombCount, equals(40));
  expect(f.height, equals(16));
  expect(f.width, equals(16));
}

_testBombCount() {
  var f = new Field();

  var bombCount = 0;
  for (var x = 0; x < 16; x++) {
    for (var y = 0; y < 16; y++) {
      if (f.get(x, y)) {
        bombCount++;
      }
    }
  }
  expect(bombCount, equals(f.bombCount));
}

_testFromSquares() {
  var f = new Field.fromSquares(2, 2, [true, true, true, false]);
  expect(f.height, equals(2));
  expect(f.width, equals(2));
  expect(f.bombCount, equals(3));
}

_testAdjacent() {
  var f = getSampleField();

  expect(f.bombCount, equals(13));

  for (var x = 0; x < f.width; x++) {
    for (var y = 0; y < f.height; y++) {
      var i = x + y * f.width;
      var adj = f.getAdjacentCount(x, y);
      expect(adj, equals(SAMPLE_FIELD[i]));
    }
  }
}

