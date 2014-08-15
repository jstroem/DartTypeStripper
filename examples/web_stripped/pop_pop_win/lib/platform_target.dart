// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.platform_target;

import 'dart:async';

abstract class PlatformTarget {
  var _initialized = false;

  factory PlatformTarget() => new _DefaultPlatform();

  PlatformTarget.base();

  get initialized => _initialized;

  initialize() {
    assert(!_initialized);
    _initialized = true;
  }

  clearValues();

  setValue(key, value);

  getValue(key);

  get size;

  get showAbout;

  toggleAbout([value]);

  get aboutChanged;
}

class _DefaultPlatform extends PlatformTarget {
  final _values = new Map<String, String>();
  final _aboutController = new StreamController(sync: true);
  var _about = false;

  _DefaultPlatform() : super.base();

  @override
  clearValues() => new Future(_values.clear);

  @override
  setValue(key, value) => new Future(() {
    _values[key] = value;
  });

  @override
  getValue(key) => new Future(() => _values[key]);

  get size => 7;

  toggleAbout([value]) {
    assert(_about != null);
    if (value == null) {
      value = !_about;
    }
    _about = value;
    _aboutController.add(null);
  }

  get showAbout => _about;

  get aboutChanged => _aboutController.stream;
}

