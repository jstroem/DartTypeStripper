// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'dart:js';

class Gauge {
  var jsOptions;
  var jsTable;
  var jsChart;


  var _value;
  get value => _value;
  set value(x) {
    _value = x;
    draw();
  }

  Gauge(element, title, this._value, options) {
    final data = [['Label', 'Value'], [title, value]];
    final vis = context["google"]["visualization"];
    jsTable = vis.callMethod('arrayToDataTable', [new JsObject.jsify(data)]);
    jsChart = new JsObject(vis["Gauge"], [element]);
    jsOptions = new JsObject.jsify(options);
    draw();
  }

  draw() {
    jsTable.callMethod('setValue', [0, 1, value]);
    jsChart.callMethod('draw', [jsTable, jsOptions]);
  }

  static load() {
    var c = new Completer();
    context["google"].callMethod(
        'load',
        ['visualization', '1', new JsObject.jsify({
        'packages': ['gauge'],
        'callback': new JsFunction.withThis(c.complete)
      })]);
    return c.future;
  }
}

// Bindings to html elements.
final visualization = querySelector('#gauge');
final slider = querySelector("#slider");

main() {
  // Setup the gauge.
  Gauge.load().then((_) {
    sliderValue() => int.parse(slider.value);

    var gauge = new Gauge(visualization, "Slider", sliderValue(), {
      'min': 0,
      'max': 280,
      'yellowFrom': 200,
      'yellowTo': 250,
      'redFrom': 250,
      'redTo': 280,
      'minorTicks': 5
    });
    // Connect slider value to gauge.
    slider.onChange.listen((_) => gauge.value = sliderValue());
  });
}

