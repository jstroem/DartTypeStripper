// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.audio;

import 'dart:math';

import 'package:stagexl/stagexl.dart';

class GameAudio {
  static final _rnd = new Random();

  static var _resourceManager;

  static const _WIN = 'win',
      _CLICK = 'click',
      _POP = 'Pop',
      _FLAG = 'flag',
      _UNFLAG = 'unflag',
      _BOMB = 'Bomb',
      _THROW_DART = 'throw';

  static initialize(resourceManager) {
    if (_resourceManager != null) throw new StateError('already initialized');
    _resourceManager = resourceManager;
  }

  static win() => _playAudio(_WIN);

  static click() => _playAudio(_CLICK);

  static pop() => _playAudio(_POP);

  static flag() => _playAudio(_FLAG);

  static unflag() => _playAudio(_UNFLAG);

  static bomb() => _playAudio(_BOMB);

  static throwDart() => _playAudio(_THROW_DART);

  static _playAudio(name) {
    if (_resourceManager == null) throw new StateError('Not initialized');
    switch (name) {
      case GameAudio._POP:
        var i = _rnd.nextInt(8);
        name = '${GameAudio._POP}$i';
        break;
      case GameAudio._BOMB:
        var i = _rnd.nextInt(4);
        name = '${GameAudio._BOMB}$i';
        break;
    }
    _resourceManager.getSoundSprite('audio').play(name);
  }
}

