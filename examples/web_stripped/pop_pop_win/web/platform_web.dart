// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.platform_web;

import 'dart:async';
import 'dart:html';
import 'package:pop_pop_win/platform_target.dart';

class PlatformWeb extends PlatformTarget {
  static const _ABOUT_HASH = '#about';
  var _sizeAccessed = false;

  final _aboutController = new StreamController(sync: true);

  PlatformWeb() : super.base() {
    window.onPopState.listen((args) => _processUrlHash());
  }

  @override
  clearValues() {
    window.localStorage.clear();
    return new Future.value();
  }

  @override
  setValue(key, value) {
    window.localStorage[key] = value;
    return new Future.value();
  }

  @override
  getValue(key) => new Future.value(window.localStorage[key]);

  get size {
    _sizeAccessed = true;
    var hash = (_urlHash == null) ? '7' : _urlHash;
    hash = hash.replaceAll('#', '');
    return int.parse(hash, onError: (e) => 7);
  }

  get showAbout => _urlHash == _ABOUT_HASH;

  get aboutChanged => _aboutController.stream;

  toggleAbout([value]) {
    var loc = window.location;
    // ensure we treat empty hash like '#', which makes comparison easy later
    var hash = loc.hash.length == 0 ? '#' : loc.hash;

    var isOpen = hash == _ABOUT_HASH;
    if (value == null) {
      // then toggle the current value
      value = !isOpen;
    }

    var targetHash = value ? _ABOUT_HASH : '#';
    if (targetHash != hash) {
      loc.assign(targetHash);
    }
    _aboutController.add(null);
  }

  get _urlHash => window.location.hash;

  _processUrlHash() {
    var loc = window.location;
    var hash = loc.hash;
    var href = loc.href;

    switch (hash) {
      case "#reset":
        assert(href.endsWith(hash));
        var newLoc = href.substring(0, href.length - hash.length);

        window.localStorage.clear();

        loc.replace(newLoc);
        break;
      case _ABOUT_HASH:
        _aboutController.add(null);
        break;
      default:
        if (hash.isNotEmpty && _sizeAccessed) {
          loc.reload();
        }
        break;
    }
  }
}

