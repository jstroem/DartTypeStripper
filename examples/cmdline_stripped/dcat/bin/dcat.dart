// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dcat;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const LINE_NUMBER = 'line-number';
var NEWLINE = '\n';

var argResults;












dcat(paths, showLineNumbers) {
  if (paths.isEmpty) {
    // No files provided as arguments. Read from stdin and print each line.
    return stdin.pipe(stdout);
  } else {
    // `Future.forEach` asynchronously runs the callback provided on
    // each `path`. `forEach` runs the callback for each element in order,
    // moving to the next element only when the Future returned by the callback
    // completes.
    return Future.forEach(paths, (path) {
      var lineNumber = 1;
      var stream = new File(path).openRead();

      // Transform the stream using a `StreamTransformer`. The transformers
      // used here convert the data to UTF8 and split string values into
      // individual lines.
      return stream.transform(
          UTF8.decoder).transform(const LineSplitter()).listen((line) {
        if (showLineNumbers) {
          stdout.write('${lineNumber++} ');
        }
        stdout.writeln(line);
      }).asFuture().catchError((_) => _handleError(path));
    });
  }
}

_handleError(path) {
  FileSystemEntity.isDirectory(path).then((isDir) {
    if (isDir) {
      print('error: $path is a directory');
    } else {
      print('error: $path not found');
    }
  });
}

main(arguments) {
  final parser =
      new ArgParser()..addFlag(LINE_NUMBER, negatable: false, abbr: 'n');

  argResults = parser.parse(arguments);
  var paths = argResults.rest;

  dcat(paths, argResults[LINE_NUMBER]);
}

