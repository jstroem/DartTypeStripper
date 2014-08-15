// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of clock;

get clientWidth => window.innerWidth;

get clientHeight => window.innerHeight;

class Balls {
  static const RADIUS2 = Ball.RADIUS * Ball.RADIUS;

  static const LT_GRAY_BALL_INDEX = 0;
  static const GREEN_BALL_INDEX = 1;
  static const BLUE_BALL_INDEX = 2;

  static const DK_GRAY_BALL_INDEX = 4;
  static const RED_BALL_INDEX = 5;
  static const MD_GRAY_BALL_INDEX = 6;

  static const PNGS = const [
      "images/ball-d9d9d9.png",
      "images/ball-009a49.png",
      "images/ball-13acfa.png",
      "images/ball-265897.png",
      "images/ball-b6b4b5.png",
      "images/ball-c0000b.png",
      "images/ball-c9c9c9.png"];

  var root;
  var lastTime;
  var balls;

  Balls()
      : lastTime = new DateTime.now().millisecondsSinceEpoch,
        balls = new List<Ball>() {
    root = new DivElement();
    document.body.nodes.add(root);
    makeAbsolute(root);
    setElementSize(root, 0.0, 0.0, 0.0, 0.0);
  }

  tick(now) {
    showFps(1000.0 / (now - lastTime + 0.01));

    var delta = min((now - lastTime) / 1000.0, 0.1);
    lastTime = now;

    // incrementally move each ball, removing balls that are offscreen
    balls = balls.where((ball) => ball.tick(delta)).toList();
    collideBalls(delta);
  }

  collideBalls(delta) {
    balls.forEach((b0) {
      balls.forEach((b1) {

        var dx = (b0.x - b1.x).abs();
        var dy = (b0.y - b1.y).abs();
        var d2 = dx * dx + dy * dy;

        if (d2 < RADIUS2) {
          // Make sure they're actually on a collision path
          // (not intersecting while moving apart).
          // This keeps balls that end up intersecting from getting stuck
          // without all the complexity of keeping them strictly separated.
          if (newDistanceSquared(delta, b0, b1) > d2) {
            return;
          }


          var d = sqrt(d2);

          if (d == 0) {
            return;
          }

          dx /= d;
          dy /= d;


          var impactx = b0.vx - b1.vx;
          var impacty = b0.vy - b1.vy;
          var impactSpeed = impactx * dx + impacty * dy;

          // Bump.
          b0.vx -= dx * impactSpeed;
          b0.vy -= dy * impactSpeed;
          b1.vx += dx * impactSpeed;
          b1.vy += dy * impactSpeed;
        }
      });
    });
  }

  newDistanceSquared(delta, b0, b1) {
    var nb0x = b0.x + b0.vx * delta;
    var nb0y = b0.y + b0.vy * delta;
    var nb1x = b1.x + b1.vx * delta;
    var nb1y = b1.y + b1.vy * delta;
    var ndx = (nb0x - nb1x).abs();
    var ndy = (nb0y - nb1y).abs();
    var nd2 = ndx * ndx + ndy * ndy;
    return nd2;
  }

  add(x, y, color) {
    balls.add(new Ball(root, x, y, color));
  }
}

class Ball {
  static const GRAVITY = 400.0;
  static const RESTITUTION = 0.8;
  static const MIN_VELOCITY = 100.0;
  static const INIT_VELOCITY = 800.0;
  static const RADIUS = 14.0;

  static var random;

  static randomVelocity() {
    if (random == null) {
      random = new Random();
    }

    return (random.nextDouble() - 0.5) * INIT_VELOCITY;
  }

  var root;
  var elem;
  var x, y;
  var vx, vy;
  var ax, ay;
  var age;

  Ball(this.root, this.x, this.y, color) {
    elem = new ImageElement(src: Balls.PNGS[color]);
    makeAbsolute(elem);
    setElementPosition(elem, x, y);
    root.nodes.add(elem);

    ax = 0.0;
    ay = GRAVITY;

    vx = randomVelocity();
    vy = randomVelocity();
  }


  tick(delta) {
    // Update velocity and position.
    vx += ax * delta;
    vy += ay * delta;

    x += vx * delta;
    y += vy * delta;

    // Handle falling off the edge.
    if ((x < RADIUS) || (x > clientWidth)) {
      elem.remove();
      return false;
    }

    // Handle ground collisions.
    if (y > clientHeight) {
      y = clientHeight.toDouble();
      vy *= -RESTITUTION;
    }

    // Position the element.
    setElementPosition(elem, x - RADIUS, y - RADIUS);

    return true;
  }
}

