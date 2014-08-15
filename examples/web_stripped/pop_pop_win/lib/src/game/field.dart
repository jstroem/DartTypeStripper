// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of pop_pop_win.game;

class Field extends Array2d<bool> {
  final bombCount;
  final _adjacents;

  factory Field([bombCount = 40, cols = 16, rows = 16, seed = null]) {
    var squares = new List<bool>.filled(rows * cols, false);
    assert(bombCount < squares.length);
    assert(bombCount > 0);

    var rnd = new Random(seed);

    // This is the most simple code, but it'll get slow as
    // bombCount approaches the square count.
    // But more efficient if bombCount << square count
    // which is expected.
    for (var i = 0; i < bombCount; i++) {
      var index;
      do {
        index = rnd.nextInt(squares.length);
      } while (squares[index]);
      squares[index] = true;
    }

    return new Field._internal(
        bombCount,
        cols,
        new UnmodifiableListView<bool>(squares));
  }

  factory Field.fromSquares(cols, rows, squares) {
    assert(cols > 0);
    assert(rows > 0);
    assert(squares.length == cols * rows);

    var count = 0;
    for (final m in squares) {
      if (m) {
        count++;
      }
    }
    assert(count > 0);
    assert(count < squares.length);

    return new Field._internal(
        count,
        cols,
        new UnmodifiableListView<bool>(squares));
  }

  Field._internal(this.bombCount, cols, source)
      : this._adjacents = new Array2d<int>(cols, source.length ~/ cols),
        super.wrap(cols, source.toList()) {
    assert(width > 0);
    assert(height > 0);
    assert(bombCount > 0);
    assert(bombCount < length);

    var count = 0;
    for (var m in this) {
      if (m) {
        count++;
      }
    }
    assert(count == bombCount);
  }

  getAdjacentCount(x, y) {
    if (get(x, y)) {
      return null;
    }

    var val = _adjacents.get(x, y);

    if (val == null) {
      val = 0;
      for (var i in getAdjacentIndices(x, y)) {
        if (this[i]) {
          val++;
        }
      }
      _adjacents.set(x, y, val);
    }
    return val;
  }

  toString() => 'w${width}h${height}m${bombCount}';
}

