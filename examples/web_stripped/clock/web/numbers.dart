// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of clock;

class ClockNumber {
  static const WIDTH = 4;
  static const HEIGHT = 7;

  var app;
  var root;
  var imgs;
  var pixels;
  var ballColor;

  ClockNumber(this.app, pos, this.ballColor) {
    imgs = new List<List<ImageElement>>(HEIGHT);

    root = new DivElement();
    makeAbsolute(root);
    setElementPosition(root, pos, 0.0);

    for (var y = 0; y < HEIGHT; ++y) {
      imgs[y] = new List<ImageElement>(WIDTH);
    }

    for (var y = 0; y < HEIGHT; ++y) {
      for (var x = 0; x < WIDTH; ++x) {
        imgs[y][x] = new ImageElement();
        root.nodes.add(imgs[y][x]);
        makeAbsolute(imgs[y][x]);
        setElementPosition(
            imgs[y][x],
            x * CountDownClock.BALL_WIDTH,
            y * CountDownClock.BALL_HEIGHT);
      }
    }
  }

  setPixels(px) {
    for (var y = 0; y < HEIGHT; ++y) {
      for (var x = 0; x < WIDTH; ++x) {
        var img = imgs[y][x];

        if (pixels != null) {
          if ((pixels[y][x] != 0) && (px[y][x] == 0)) {
            scheduleMicrotask(() {
              var r = img.getBoundingClientRect();
              var absx = r.left;
              var absy = r.top;

              app.balls.add(absx, absy, ballColor);
            });
          }
        }

        img.src = px[y][x] != 0 ? Balls.PNGS[ballColor] : Balls.PNGS[6];
      }
    }

    pixels = px;
  }
}

class Colon {
  var root;

  Colon(xpos, ypos) {
    root = new DivElement();
    makeAbsolute(root);
    setElementPosition(root, xpos, ypos);

    var dot = new ImageElement(src: Balls.PNGS[Balls.DK_GRAY_BALL_INDEX]);
    root.nodes.add(dot);
    makeAbsolute(dot);
    setElementPosition(dot, 0.0, 2.0 * CountDownClock.BALL_HEIGHT);

    dot = new ImageElement(src: Balls.PNGS[Balls.DK_GRAY_BALL_INDEX]);
    root.nodes.add(dot);
    makeAbsolute(dot);
    setElementPosition(dot, 0.0, 4.0 * CountDownClock.BALL_HEIGHT);
  }
}

class ClockNumbers {
  static const PIXELS = const [
      const [
          const [1, 1, 1, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 1, 1, 1]],
      const [
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1]],
      const [
          const [1, 1, 1, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [1, 1, 1, 1],
          const [1, 0, 0, 0],
          const [1, 0, 0, 0],
          const [1, 1, 1, 1]],
      const [
          const [1, 1, 1, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [1, 1, 1, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [1, 1, 1, 1]],
      const [
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 1, 1, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1]],
      const [
          const [1, 1, 1, 1],
          const [1, 0, 0, 0],
          const [1, 0, 0, 0],
          const [1, 1, 1, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [1, 1, 1, 1]],
      const [
          const [1, 1, 1, 1],
          const [1, 0, 0, 0],
          const [1, 0, 0, 0],
          const [1, 1, 1, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 1, 1, 1]],
      const [
          const [1, 1, 1, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1]],
      const [
          const [1, 1, 1, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 1, 1, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 1, 1, 1]],
      const [
          const [1, 1, 1, 1],
          const [1, 0, 0, 1],
          const [1, 0, 0, 1],
          const [1, 1, 1, 1],
          const [0, 0, 0, 1],
          const [0, 0, 0, 1],
          const [1, 1, 1, 1]]];
}

