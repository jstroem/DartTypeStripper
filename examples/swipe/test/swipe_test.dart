// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library swipe_test;

import '../web/swipe.dart' as swipe;

/**
 * This test exists to ensure that the swipe sample compiles without errors.
 */
void main() {
// Reference the swipe library so that the import isn't marked as unused.
  var t = swipe.timer;
  t = null;
  print(t);
}
