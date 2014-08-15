// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library swipe;

import 'dart:async';
import 'dart:html';
import 'dart:math';

var target;

var figureWidth;

var anglePos = 0.0;

var timer;

main() {
  target = querySelector('#target');

  initialize3D();


  var touchStartX;

  target.onTouchStart.listen((event) {
    event.preventDefault();

    if (event.touches.length > 0) {
      touchStartX = event.touches[0].page.x;
    }
  });

  target.onTouchMove.listen((event) {
    event.preventDefault();

    if (touchStartX != null && event.touches.length > 0) {
      var newTouchX = event.touches[0].page.x;

      if (newTouchX > touchStartX) {
        spinFigure(target, (newTouchX - touchStartX) ~/ 20 + 1);
        touchStartX = null;
      } else if (newTouchX < touchStartX) {
        spinFigure(target, (newTouchX - touchStartX) ~/ 20 - 1);
        touchStartX = null;
      }
    }
  });

  target.onTouchEnd.listen((event) {
    event.preventDefault();

    touchStartX = null;
  });

  // Handle key events.
  document.onKeyDown.listen((event) {
    switch (event.keyCode) {
      case KeyCode.LEFT:
        startSpin(target, -1);
        break;
      case KeyCode.RIGHT:
        startSpin(target, 1);
        break;
    }
  });

  document.onKeyUp.listen((event) => stopSpin());
}

initialize3D() {
  target.classes.add("transformable");

  var childCount = target.children.length;

  scheduleMicrotask(() {
    var width = querySelector("#target").client.width;
    figureWidth = (width / 2) ~/ tan(PI / childCount);

    target.style.transform = "translateZ(-${figureWidth}px)";

    var radius = (figureWidth * 1.2).round();
    querySelector('#container2').style.width = "${radius}px";

    for (var i = 0; i < childCount; i++) {
      var panel = target.children[i];

      panel.classes.add("transformable");

      panel.style.transform =
          "rotateY(${i * (360 / childCount)}deg) translateZ(${radius}px)";
    }

    spinFigure(target, -1);
  });
}

spinFigure(figure, direction) {
  var childCount = target.children.length;

  anglePos += (360.0 / childCount) * direction;

  figure.style.transform =
      'translateZ(-${figureWidth}px) rotateY(${anglePos}deg)';
}




startSpin(figure, direction) {
  // If we're not already spinning -
  if (timer == null) {
    spinFigure(figure, direction);

    timer = new Timer.periodic(
        const Duration(milliseconds: 100),
        (t) => spinFigure(figure, direction));
  }
}




stopSpin() {
  if (timer != null) {
    timer.cancel();
    timer = null;
  }
}

