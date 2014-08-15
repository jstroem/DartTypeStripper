// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * A solar system visualization.
 */

library solar;

import 'dart:async';
import 'dart:html';
import 'dart:math';

main() {
  var canvas = querySelector("#area");
  scheduleMicrotask(new SolarSystem(canvas).start);
}

var notes = querySelector("#fps");
var fpsAverage;


showFps(fps) {
  if (fpsAverage == null) fpsAverage = fps;
  fpsAverage = fps * 0.05 + fpsAverage * 0.95;
  notes.text = "${fpsAverage.round()} fps";
}

/**
 * A representation of the solar system.
 *
 * This class maintains a list of planetary bodies, knows how to draw its
 * background and the planets, and requests that it be redraw at appropriate
 * intervals using the [Window.requestAnimationFrame] method.
 */
class SolarSystem {
  var canvas;

  var width;
  var height;

  var sun;

  var renderTime;

  SolarSystem(this.canvas);

  // Initialize the planets and start the simulation.
  start() {

    var rect = canvas.parent.client;
    width = rect.width;
    height = rect.height;
    canvas.width = width;

    // Create sun.
    final mercury = new PlanetaryBody(this, "orange", 0.382, 0.387, 0.241);
    final venus = new PlanetaryBody(this, "green", 0.949, 0.723, 0.615);
    final earth = new PlanetaryBody(this, "#33f", 1.0, 1.0, 1.0);
    final moon = new PlanetaryBody(this, "gray", 0.2, 0.14, 0.075);
    earth.addPlanet(moon);

    final mars = new PlanetaryBody(this, "red", 0.532, 1.524, 1.88);

    final f = 0.1;
    final h = 1 / 1500.0;
    final g = 1 / 72.0;

    final jupiter = new PlanetaryBody(this, "gray", 4.0, 5.203, 11.86);
    final io = new PlanetaryBody(this, "gray", 3.6 * f, 421 * h, 1.769 * g);
    final europa = new PlanetaryBody(this, "gray", 3.1 * f, 671 * h, 3.551 * g);
    final ganymede =
        new PlanetaryBody(this, "gray", 5.3 * f, 1070 * h, 7.154 * g);
    final callisto =
        new PlanetaryBody(this, "gray", 4.8 * f, 1882 * h, 16.689 * g);
    jupiter
        ..addPlanet(io)
        ..addPlanet(europa)
        ..addPlanet(ganymede)
        ..addPlanet(callisto);

    sun = new PlanetaryBody(this, "#ff2", 14.0)
        ..addPlanet(mercury)
        ..addPlanet(venus)
        ..addPlanet(earth)
        ..addPlanet(mars)
        ..addPlanet(jupiter);

    addAsteroidBelt(sun, 150);

    requestRedraw();
  }

  draw(_) {
    var time = new DateTime.now().millisecondsSinceEpoch;
    if (renderTime != null) showFps(1000 / (time - renderTime));
    renderTime = time;

    var context = canvas.context2D;
    drawBackground(context);
    drawPlanets(context);
    requestRedraw();
  }

  drawBackground(context) {
    context.clearRect(0, 0, width, height);
  }

  drawPlanets(context) {
    sun.draw(context, new Point(width / 2, height / 2));
  }

  requestRedraw() {
    window.requestAnimationFrame(draw);
  }

  addAsteroidBelt(body, count) {
    var random = new Random();

    // Asteroids are generally between 2.06 and 3.27 AUs.
    for (var i = 0; i < count; i++) {
      var radius = 2.06 + random.nextDouble() * (3.27 - 2.06);
      body.addPlanet(
          new PlanetaryBody(this, "#777", 0.1 * random.nextDouble(), radius, radius * 2));
    }
  }

  normalizeOrbitRadius(r) => r * (width / 10.0);

  normalizePlanetSize(r) => log(r + 1) * (width / 100.0);
}

/**
 * A representation of a plantetary body.
 * This class can calculate its position for a given time index,
 * and draw itself and any child planets.
 */
class PlanetaryBody {
  final color;
  final orbitPeriod;
  final solarSystem;

  var bodySize;
  var orbitRadius;
  var orbitSpeed;

  final planets = <PlanetaryBody>[];

  PlanetaryBody(this.solarSystem, this.color, this.bodySize, [this.orbitRadius =
      0.0, this.orbitPeriod = 0.0]) {
    bodySize = solarSystem.normalizePlanetSize(bodySize);
    orbitRadius = solarSystem.normalizeOrbitRadius(orbitRadius);
    orbitSpeed = calculateSpeed(orbitPeriod);
  }

  addPlanet(planet) {
    planets.add(planet);
  }

  draw(context, p) {
    var pos = calculatePos(p);
    drawSelf(context, pos);
    drawChildren(context, pos);
  }

  drawSelf(context, p) {
    // Check for clipping.
    if (p.x + bodySize < 0 || p.x - bodySize >= context.canvas.width) return;
    if (p.y + bodySize < 0 || p.y - bodySize >= context.canvas.height) return;

    // Draw the figure.
    context
        ..lineWidth = 0.5
        ..fillStyle = color
        ..strokeStyle = color;

    if (bodySize >= 2.0) {
      context
          ..shadowOffsetX = 2
          ..shadowOffsetY = 2
          ..shadowBlur = 2
          ..shadowColor = "#ddd";
    }

    context
        ..beginPath()
        ..arc(p.x, p.y, bodySize, 0, PI * 2, false)
        ..fill()
        ..closePath();

    context
        ..shadowOffsetX = 0
        ..shadowOffsetY = 0
        ..shadowBlur = 0;

    context
        ..beginPath()
        ..arc(p.x, p.y, bodySize, 0, PI * 2, false)
        ..fill()
        ..closePath()
        ..stroke();
  }

  drawChildren(context, p) {
    for (var planet in planets) planet.draw(context, p);
  }

  calculateSpeed(period) =>
      period == 0.0 ? 0.0 : 1 / (60.0 * 24.0 * 2 * period);

  calculatePos(p) {
    if (orbitSpeed == 0.0) return p;
    var angle = solarSystem.renderTime * orbitSpeed;
    return new Point(
        orbitRadius * cos(angle) + p.x,
        orbitRadius * sin(angle) + p.y);
  }
}

