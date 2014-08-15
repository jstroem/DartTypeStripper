// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library build_dart;

import "dart:io";
import "package:args/args.dart";

var cleanBuild;
var fullBuild;
var useMachineInterface;

var changedFiles;
var removedFiles;








main(arguments) {
  processArgs(arguments);

  if (cleanBuild) {
    handleCleanCommand();
  } else if (fullBuild) {
    handleFullBuild();
  } else {
    handleChangedFiles(changedFiles);
    handleRemovedFiles(removedFiles);
  }

  // Return a non-zero code to indicate a build failure.
  //exit(1);
}




processArgs(arguments) {
  var parser = new ArgParser();
  parser.addOption(
      "changed",
      help: "the file has changed since the last build",
      allowMultiple: true);
  parser.addOption(
      "removed",
      help: "the file was removed since the last build",
      allowMultiple: true);
  parser.addFlag("clean", negatable: false, help: "remove any build artifacts");
  parser.addFlag("full", negatable: false, help: "perform a full build");
  parser.addFlag(
      "machine",
      negatable: false,
      help: "produce warnings in a machine parseable format");
  parser.addFlag("help", negatable: false, help: "display this help and exit");

  var args = parser.parse(arguments);

  if (args["help"]) {
    print(parser.getUsage());
    exit(0);
  }

  changedFiles = args["changed"];
  removedFiles = args["removed"];

  useMachineInterface = args["machine"];

  cleanBuild = args["clean"];
  fullBuild = args["full"];
}




handleCleanCommand() {
  var current = Directory.current;
  current.list(recursive: true).listen((entity) {
    if (entity is File) _maybeClean(entity);
  });
}




handleFullBuild() {
  var files = <String>[];

  Directory.current.list(recursive: true).listen((entity) {
    if (entity is File) {
      files.add((entity as File).resolveSymbolicLinksSync());
    }
  }, onDone: () => handleChangedFiles(files));
}




handleChangedFiles(files) {
  files.forEach(_processFile);
}




handleRemovedFiles(files) {

}




_processFile(arg) {
  if (arg.endsWith(".foo")) {
    print("processing: ${arg}");

    var file = new File(arg);

    var contents = file.readAsStringSync();

    var outFile = new File("${arg}bar");

    var out = outFile.openWrite();
    out.writeln("// processed from ${file.path}:");
    if (contents != null) {
      out.write(contents);
    }
    out.close();

    _findErrors(arg);

    print("wrote: ${outFile.path}");
  }
}

_findErrors(arg) {
  var file = new File(arg);

  var lines = file.readAsLinesSync();

  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains("woot") && !lines[i].startsWith("//")) {
      if (useMachineInterface) {
        // Ideally, we should emit the charStart and charEnd params as well.
        print(
            '[{"method":"error","params":{"file":"$arg","line":${i+1},'
                '"message":"woot not supported"}}]');
      }
    }
  }
}




_maybeClean(file) {
  if (file.path.endsWith(".foobar")) {
    file.delete();
  }
}

