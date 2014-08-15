// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.game_manager;

import 'dart:async';

import 'game_storage.dart';
import 'game.dart';

abstract class GameManager {
  final _width, _height, _bombCount;
  final _gameStorage = new GameStorage();

  var _game;
  var _updatedEventId;
  var _gameStateChangedId;
  var _clockTimer;

  GameManager(this._width, this._height, this._bombCount) {
    newGame();
  }

  get game => _game;

  get bestTimeUpdated => _gameStorage.bestTimeUpdated;

  get bestTimeMilliseconds =>
      _gameStorage.getBestTimeMilliseconds(_width, _height, _bombCount);

  newGame() {
    if (_updatedEventId != null) {
      assert(_game != null);
      assert(_gameStateChangedId != null);
      _updatedEventId.cancel();
      _gameStateChangedId.cancel();
      _gameStateChanged(GameState.reset);
    }
    final f = new Field(_bombCount, _width, _height);
    _game = new Game(f);
    _updatedEventId = _game.updated.listen((_) => gameUpdated());
    _gameStateChangedId = _game.stateChanged.listen(_gameStateChanged);
  }

  gameUpdated() {}

  resetScores() {
    _gameStorage.reset();
  }

  _click(x, y, alt) {
    final ss = _game.getSquareState(x, y);

    if (alt) {
      if (ss == SquareState.hidden) {
        _game.setFlag(x, y, true);
      } else if (ss == SquareState.flagged) {
        _game.setFlag(x, y, false);
      } else if (ss == SquareState.revealed) {
        _game.reveal(x, y);
      }
    } else {
      if (ss == SquareState.hidden) {
        _game.reveal(x, y);
      }
    }
  }

  updateClock() {
    if (_clockTimer == null && _game.state == GameState.started) {
      _clockTimer = new Timer(const Duration(seconds: 1), updateClock);
    } else if (_clockTimer != null && _game.state != GameState.started) {
      _clockTimer.cancel();
      _clockTimer = null;
    }
  }

  onNewBestTime(value) {}

  onGameStateChanged(value) {}

  get _canClick {
    return _game.state == GameState.reset || _game.state == GameState.started;
  }

  _gameStateChanged(newState) {
    _gameStorage.recordState(newState);
    if (newState == GameState.won) {
      _gameStorage.updateBestTime(_game).then((newBestTime) {
        if (newBestTime) {
          bestTimeMilliseconds.then((val) {
            onNewBestTime(val);
          });
        }
      });
    }
    updateClock();
    onGameStateChanged(newState);
  }
}

