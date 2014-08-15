// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of spirodraw;

typedef void PickerListener(selectedColor);

class ColorPicker {
  static const hexValues = const ['00', '33', '66', '99', 'CC', 'FF'];
  static const COLS = 18;
  // Block height, width, padding
  static const BH = 10;
  static const BW = 10;
  static const BP = 1;
  final _listeners;
  var canvasElement;
  var _selectedColor = 'red';
  final height = 160;
  final width = 180;
  var ctx;

  ColorPicker(this.canvasElement) : _listeners = [] {
    ctx = canvasElement.context2D;
    drawPalette();
    addHandlers();
    showSelected();
  }

  get selectedColor => _selectedColor;

  set selectedColor(color) {
    _selectedColor = color;

    showSelected();
    fireSelected();
  }

  onMouseMove(event) {
    var x = event.offset.x;
    var y = event.offset.y - 40;
    if ((y < 0) || (x >= width)) {
      return;
    }
    ctx.fillStyle = getHexString(getColorIndex(x, y));
    ctx.fillRect(0, 0, width / 2, 30);
  }

  onMouseDown(event) {
    event.stopPropagation();
    var elt = event.target;
    var x = event.offset.x;
    var y = event.offset.y - 40;
    if ((y < 0) || (x >= width)) {
      return;
    }
    selectedColor = getHexString(getColorIndex(x, y));
  }




  addListener(listener) {
    _listeners.add(listener);
  }

  addHandlers() {
    canvasElement.onMouseMove.listen(onMouseMove);
    canvasElement.onMouseDown.listen(onMouseDown);
  }

  drawPalette() {
    var i = 0;
    for (var r = 0; r < 256; r += 51) {
      for (var g = 0; g < 256; g += 51) {
        for (var b = 0; b < 256; b += 51) {
          var color = getHexString(i);
          ctx.fillStyle = color;
          var x = BW * (i % COLS);
          var y = BH * (i ~/ COLS) + 40;
          ctx.fillRect(x + BP, y + BP, BW - 2 * BP, BH - 2 * BP);
          i++;
        }
      }
    }
  }

  fireSelected() {
    for (final listener in _listeners) {
      listener(_selectedColor);
    }
  }

  getColorIndex(x, y) {

    var i = y ~/ BH * COLS + x ~/ BW;
    return i;
  }

  showSelected() {
    ctx.fillStyle = _selectedColor;
    ctx.fillRect(width / 2, 0, width / 2, 30);
    ctx.fillStyle = "white";
    ctx.fillRect(0, 0, width / 2, 30);
  }

  getHexString(value) {
    var i = value.floor().toInt();

    var r = (i ~/ 36) % 6;
    var g = (i % 36) ~/ 6;
    var b = i % 6;

    return '#${hexValues[r]}${hexValues[g]}${hexValues[b]}';
  }
}

