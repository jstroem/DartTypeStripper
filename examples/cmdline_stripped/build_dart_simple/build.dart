// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library build_dart_simple;

import "dart:io";






main(arguments) {
  for (var arg in arguments) {
    if (arg.startsWith("--changed=")) {
      var file = arg.substring("--changed=".length);

      if (file.endsWith(".foo")) {
        _processFile(file);
      }
    }
  }
}

_processFile(file) {
  var contents = new File(file).readAsStringSync();

  if (contents != null) {
    var out = new File("${file}bar").openWrite();
    out.write("// processed from ${file}:\n${contents}");
    out.close();
  }
}

