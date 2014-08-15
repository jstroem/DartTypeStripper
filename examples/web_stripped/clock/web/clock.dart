// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library clock;

import 'dart:async';
import 'dart:html';
import 'dart:math';

part 'balls.dart';
part 'numbers.dart';

main() {
  new CountDownClock();
}

var fpsAverage;




showFps(fps) {
  if (fpsAverage == null) {
    fpsAverage = fps;
  } else {
    fpsAverage = fps * 0.05 + fpsAverage * 0.95;

    querySelector("#notes").text = "${fpsAverage.round().toInt()} fps";
  }
}

class CountDownClock {
  static const NUMBER_SPACING = 19.0;
  static const BALL_WIDTH = 19.0;
  static const BALL_HEIGHT = 19.0;

  var hours = new List<ClockNumber>(2);
  var minutes = new List<ClockNumber>(2);
  var seconds = new List<ClockNumber>(2);
  var displayedHour = -1;
  var displayedMinute = -1;
  var displayedSecond = -1;
  var balls = new Balls();

  CountDownClock() {
    var parent = querySelector("#canvas-content");

    createNumbers(parent, parent.client.width, parent.client.height);

    updateTime(new DateTime.now());

    window.requestAnimationFrame(tick);
  }

  tick(time) {
    updateTime(new DateTime.now());
    balls.tick(time);
    window.requestAnimationFrame(tick);
  }

  updateTime(now) {
    if (now.hour != displayedHour) {
      setDigits(pad2(now.hour), hours);
      displayedHour = now.hour;
    }

    if (now.minute != displayedMinute) {
      setDigits(pad2(now.minute), minutes);
      displayedMinute = now.minute;
    }

    if (now.second != displayedSecond) {
      setDigits(pad2(now.second), seconds);
      displayedSecond = now.second;
    }
  }

  setDigits(digits, numbers) {
    for (var i = 0; i < numbers.length; ++i) {
      var digit = digits.codeUnitAt(i) - '0'.codeUnitAt(0);
      numbers[i].setPixels(ClockNumbers.PIXELS[digit]);
    }
  }

  pad3(number) {
    if (number < 10) {
      return "00${number}";
    }
    if (number < 100) {
      return "0${number}";
    }
    return "${number}";
  }

  pad2(number) {
    if (number < 10) {
      return "0${number}";
    }
    return "${number}";
  }

  createNumbers(parent, width, height) {
    var root = new DivElement();
    makeRelative(root);
    root.style.textAlign = 'center';
    querySelector("#canvas-content").nodes.add(root);

    var hSize =
        (BALL_WIDTH * ClockNumber.WIDTH + NUMBER_SPACING) * 6 +
        (BALL_WIDTH + NUMBER_SPACING) * 2;
    hSize -= NUMBER_SPACING;

    var vSize = BALL_HEIGHT * ClockNumber.HEIGHT;

    var x = (width - hSize) / 2;
    var y = (height - vSize) / 3;

    for (var i = 0; i < hours.length; ++i) {
      hours[i] = new ClockNumber(this, x, Balls.BLUE_BALL_INDEX);
      root.nodes.add(hours[i].root);
      setElementPosition(hours[i].root, x, y);
      x += BALL_WIDTH * ClockNumber.WIDTH + NUMBER_SPACING;
    }

    root.nodes.add(new Colon(x, y).root);
    x += BALL_WIDTH + NUMBER_SPACING;

    for (var i = 0; i < minutes.length; ++i) {
      minutes[i] = new ClockNumber(this, x, Balls.RED_BALL_INDEX);
      root.nodes.add(minutes[i].root);
      setElementPosition(minutes[i].root, x, y);
      x += BALL_WIDTH * ClockNumber.WIDTH + NUMBER_SPACING;
    }

    root.nodes.add(new Colon(x, y).root);
    x += BALL_WIDTH + NUMBER_SPACING;

    for (var i = 0; i < seconds.length; ++i) {
      seconds[i] = new ClockNumber(this, x, Balls.GREEN_BALL_INDEX);
      root.nodes.add(seconds[i].root);
      setElementPosition(seconds[i].root, x, y);
      x += BALL_WIDTH * ClockNumber.WIDTH + NUMBER_SPACING;
    }
  }
}

makeAbsolute(elem) {
  elem.style.left = '0px';
  elem.style.top = '0px';
  elem.style.position = 'absolute';
}

makeRelative(elem) {
  elem.style.position = 'relative';
}

setElementPosition(elem, x, y) {
  elem.style.transform = 'translate(${x}px, ${y}px)';
}

setElementSize(elem, l, t, r, b) {
  setElementPosition(elem, l, t);
  elem.style.right = "${r}px";
  elem.style.bottom = "${b}px";
}

