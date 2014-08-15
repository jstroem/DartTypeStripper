// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.game_storage;

import 'dart:async';

import 'game.dart';
import 'platform.dart';

class GameStorage {
  static const _gameCountKey = 'gameCount';
  final _bestTimeUpdated = new StreamController();
  final _cache = new Map<String, String>();

  get gameCount => _getIntValue(_gameCountKey);

  get bestTimeUpdated => _bestTimeUpdated.stream;

  recordState(state) {
    assert(state != null);
    _incrementIntValue(state.name);
  }

  updateBestTime(game) {
    assert(game != null);
    assert(game.state == GameState.won);

    var w = game.field.width;
    var h = game.field.height;
    var m = game.field.bombCount;
    var duration = game.duration.inMilliseconds;

    var key = _getKey(w, h, m);

    return _getIntValue(key, null).then((currentScore) {
      if (currentScore == null || currentScore > duration) {
        _setIntValue(key, duration);
        _bestTimeUpdated.add(null);
        return true;
      } else {
        return false;
      }
    });
  }

  getBestTimeMilliseconds(width, height, bombCount) {
    final key = _getKey(width, height, bombCount);
    return _getIntValue(key, null);
  }

  reset() {
    _cache.clear();
    return targetPlatform.clearValues();
  }

  _getIntValue(key, [defaultValue = 0]) {
    assert(key != null);
    if (_cache.containsKey(key)) {
      return new Future.value(_parseValue(_cache[key], defaultValue));
    }

    return targetPlatform.getValue(key).then((strValue) {
      _cache[key] = strValue;
      return _parseValue(strValue, defaultValue);
    });
  }

  _setIntValue(key, value) {
    assert(key != null);
    _cache.remove(key);
    var val = (value == null) ? null : value.toString();
    return targetPlatform.setValue(key, val);
  }

  _incrementIntValue(key) {
    return _getIntValue(key).then((val) {
      return _setIntValue(key, val + 1);
    });
  }

  static _getKey(w, h, m) => "w$w-h$h-m$m";

  static _parseValue(value, defaultValue) {
    if (value == null) {
      return defaultValue;
    } else {
      return int.parse(value);
    }
  }
}

