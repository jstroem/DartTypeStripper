// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library spirodraw;

import 'dart:html';
import 'dart:math' as Math;

part "colorpicker.dart";

main() {
  new Spirodraw().go();
}

class Spirodraw {
  static var PI2 = Math.PI * 2;
  var doc;

  var RUnits, rUnits, dUnits;

  var R, r, d;
  var fixedRadiusSlider, wheelRadiusSlider, penRadiusSlider, penWidthSlider,
      speedSlider;
  var inOrOut;
  var mainDiv;
  var lastX, lastY;
  var height, width, xc, yc;
  var maxTurns;
  var frontCanvas, backCanvas;
  var front, back;
  var paletteElement;
  var colorPicker;
  var penColor = "red";
  var penWidth;
  var rad = 0.0;
  var stepSize;
  var animationEnabled = true;
  var numPoints;
  var speed;
  var run;

  Spirodraw() {
    doc = window.document;
    inOrOut = doc.querySelector("#in_out");
    fixedRadiusSlider = doc.querySelector("#fixed_radius");
    wheelRadiusSlider = doc.querySelector("#wheel_radius");
    penRadiusSlider = doc.querySelector("#pen_radius");
    penWidthSlider = doc.querySelector("#pen_width");
    speedSlider = doc.querySelector("#speed");
    mainDiv = doc.querySelector("#main");
    frontCanvas = doc.querySelector("#canvas");
    front = frontCanvas.context2D;
    backCanvas = new Element.tag("canvas");
    back = backCanvas.context2D;
    paletteElement = doc.querySelector("#palette");
    window.onResize.listen(onResize);
    initControlPanel();
  }

  go() {
    onResize(null);
  }

  onResize(event) {
    height = window.innerHeight;
    width = window.innerWidth - 270;
    yc = height ~/ 2;
    xc = width ~/ 2;
    frontCanvas
        ..height = height
        ..width = width;
    backCanvas
        ..height = height
        ..width = width;
    clear();
  }

  initControlPanel() {
    inOrOut.onChange.listen((_) => refresh());
    fixedRadiusSlider.onChange.listen((_) => refresh());
    wheelRadiusSlider.onChange.listen((_) => refresh());
    speedSlider.onChange.listen(onSpeedChange);
    penRadiusSlider.onChange.listen((_) => refresh());
    penWidthSlider.onChange.listen(onPenWidthChange);

    colorPicker = new ColorPicker(paletteElement);
    colorPicker.addListener((color) => onColorChange(color));

    doc.querySelector("#start").onClick.listen((_) => start());
    doc.querySelector("#stop").onClick.listen((_) => stop());
    doc.querySelector("#clear").onClick.listen((_) => clear());
    doc.querySelector("#lucky").onClick.listen((_) => lucky());
  }

  onColorChange(color) {
    penColor = color;
    drawFrame(rad);
  }

  onSpeedChange(event) {
    speed = speedSlider.valueAsNumber;
    stepSize = calcStepSize();
  }

  onPenWidthChange(event) {
    penWidth = penWidthSlider.valueAsNumber.toInt();
    drawFrame(rad);
  }

  refresh() {
    stop();
    // Reset
    lastX = lastY = 0;


    var min = Math.min(height, width);
    var pixelsPerUnit = min / 40;
    RUnits = fixedRadiusSlider.valueAsNumber.toInt();
    R = RUnits * pixelsPerUnit;
    // Scale inner radius and pen distance in units of fixed radius
    rUnits = wheelRadiusSlider.valueAsNumber.toInt();
    r = rUnits * R / RUnits * int.parse(inOrOut.value);
    dUnits = penRadiusSlider.valueAsNumber.toInt();
    d = dUnits * R / RUnits;
    numPoints = calcNumPoints();
    maxTurns = calcTurns();
    onSpeedChange(null);
    penWidth = penWidthSlider.valueAsNumber.toInt();
    drawFrame(0.0);
  }

  calcNumPoints() {
    // Empirically, treat it like an oval.
    if (dUnits == 0 || rUnits == 0) return 2;

    var gcf_ = gcf(RUnits, rUnits);
    var n = RUnits ~/ gcf_;
    var d_ = rUnits ~/ gcf_;
    if (n % 2 == 1) return n;
    if (d_ % 2 == 1) return n;
    return n ~/ 2;
  }

  calcStepSize() => speed / 100 * maxTurns / numPoints;

  drawFrame(theta) {
    if (animationEnabled) {
      front
          ..clearRect(0, 0, width, height)
          ..drawImage(backCanvas, 0, 0);
      drawFixed();
    }
    drawWheel(theta);
  }

  animate(time) {
    if (run && rad <= maxTurns * PI2) {
      rad += stepSize;
      drawFrame(rad);
      window.requestAnimationFrame(animate);
    } else {
      stop();
    }
  }

  start() {
    refresh();
    rad = 0.0;
    run = true;
    window.requestAnimationFrame(animate);
  }

  calcTurns() {
    // compute ratio of wheel radius to big R then find LCM
    if ((dUnits == 0) || (rUnits == 0)) return 1;
    var ru = rUnits.abs();
    var wrUnits = RUnits + rUnits;
    var g = gcf(wrUnits, ru);
    return ru ~/ g;
  }

  stop() {
    run = false;
    // Show drawing only
    front
        ..clearRect(0, 0, width, height)
        ..drawImage(backCanvas, 0, 0);
    // Reset angle
    rad = 0.0;
  }

  clear() {
    stop();
    back.clearRect(0, 0, width, height);
    refresh();
  }





  lucky() {
    var rand = new Math.Random();
    wheelRadiusSlider.valueAsNumber = rand.nextDouble() * 9;
    penRadiusSlider.valueAsNumber = rand.nextDouble() * 9;
    penWidthSlider.valueAsNumber = 1 + rand.nextDouble() * 9;
    colorPicker.selectedColor = colorPicker.getHexString(
        rand.nextDouble() * 215);
    start();
  }

  drawFixed() {
    if (animationEnabled) {
      front
          ..beginPath()
          ..lineWidth = 2
          ..strokeStyle = "gray"
          ..arc(xc, yc, R, 0, PI2, true)
          ..closePath()
          ..stroke();
    }
  }





  drawWheel(theta) {
    var wx = xc + ((R + r) * Math.cos(theta));
    var wy = yc - ((R + r) * Math.sin(theta));
    if (animationEnabled) {
      if (rUnits > 0) {
        // Draw ring
        front
            ..beginPath()
            ..arc(wx, wy, r.abs(), 0, PI2, true)
            ..closePath()
            ..stroke();
        // Draw center
        front
            ..lineWidth = 1
            ..beginPath()
            ..arc(wx, wy, 3, 0, PI2, true)
            ..fillStyle = "black"
            ..fill()
            ..closePath()
            ..stroke();
      }
    }
    drawTip(wx, wy, theta);
  }








  drawTip(wx, wy, theta) {

    var rot = (r == 0) ? theta : theta * (R + r) / r;

    var tx = wx + d * Math.cos(rot);
    var ty = wy - d * Math.sin(rot);
    if (animationEnabled) {
      front
          ..beginPath()
          ..fillStyle = penColor
          ..arc(tx, ty, penWidth / 2 + 2, 0, PI2, true)
          ..fill()
          ..moveTo(wx, wy)
          ..strokeStyle = "black"
          ..lineTo(tx, ty)
          ..closePath()
          ..stroke();
    }
    drawSegmentTo(tx, ty);
  }

  drawSegmentTo(tx, ty) {
    if (lastX > 0) {
      back
          ..beginPath()
          ..strokeStyle = penColor
          ..lineWidth = penWidth
          ..moveTo(lastX, lastY)
          ..lineTo(tx, ty)
          ..closePath()
          ..stroke();
    }
    lastX = tx;
    lastY = ty;
  }
}

gcf(n, d) {
  if (n == d) return n;
  var max = Math.max(n, d);

  for (var i = max ~/ 2; i > 1; i--) {
    if ((n % i == 0) && (d % i == 0)) return i;
  }

  return 1;
}

