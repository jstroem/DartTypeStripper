// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.platform_chrome_app;

import 'dart:async';

import 'package:pop_pop_win/platform_target.dart';
import 'package:chrome/gen/storage.dart';

class PlatformChromeApp extends PlatformTarget {
  final _aboutController = new StreamController(sync: true);
  var _about = false;

  get size => 7;

  PlatformChromeApp() : super.base();

  clearValues() => storage.local.clear();

  setValue(key, value) => storage.local.set({
    key: value
  });

  getValue(key) => storage.local.get(key).then((values) => values[key]);

  get showAbout => _about;

  get aboutChanged => _aboutController.stream;

  toggleAbout([value]) {
    assert(_about != null);
    if (value == null) {
      value = !_about;
    }
    _about = value;
    _aboutController.add(null);
  }
}

