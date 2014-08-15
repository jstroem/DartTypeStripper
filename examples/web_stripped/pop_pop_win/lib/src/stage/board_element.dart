// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.stage.board_element;

import 'package:bot/bot.dart' show Array2d;
import 'package:stagexl/stagexl.dart';

import 'package:pop_pop_win/src/game.dart';
import 'game_element.dart';
import 'square_element.dart';

class BoardElement extends Sprite {
  var _elements;

  BoardElement(gameElement) {
    addTo(gameElement);

    _elements = new Array2d<SquareElement>(game.field.width, game.field.height);

    var scaledSize = SquareElement.SIZE * _boardScale;
    for (var i = 0; i < _elements.length; i++) {
      var coords = _elements.getCoordinate(i);
      var se = new SquareElement(coords.item1, coords.item2)
          ..x = coords.item1 * scaledSize
          ..y = coords.item2 * scaledSize
          ..scaleX = _boardScale
          ..scaleY = _boardScale
          ..addTo(this);

      _elements[i] = se;
      se.updateState();
    }

  }

  get gameElement => parent;
  get _boardScale => gameElement.boardScale;
  get _boardSize => gameElement.boardSize;
  get squares => _elements;
  get game => gameElement.game;
  get _stage => gameElement.manager.stage;

  get opaqueAtlas => gameElement.resourceManager.getTextureAtlas('opaque');
}

