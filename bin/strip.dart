#!/usr/bin/env dart

import 'dart:io';

import 'package:analyzer/src/services/formatter_impl.dart';

main(List<String> args) {
  print('working dir ${new File('.').resolveSymbolicLinksSync()}');

  if (args.length == 0) {
    print('Usage: parser_driver [files_to_parse]');
    exit(0);
  }

  for (var arg in args) {
    CodeFormatter cf = new StripCodeFormatterImpl(const FormatterOptions());
    File file = new File(arg); 
    var src = file.readAsStringSync();
    FormattedSource fs = cf.format(CodeKind.COMPILATION_UNIT, src);
    print(fs.source);
  }
}

class StripCodeFormatterImpl extends CodeFormatterImpl {
  
  StripCodeFormatterImpl(options):super(options);
  
  @override
  FormattedSource format(CodeKind kind, String source, {int offset, int end,
      int indentationLevel: 0, Selection selection: null}) {

    var startToken = tokenize(source);
    checkForErrors();

    var node = parse(kind, startToken);
    checkForErrors();

    var formatter = new StripSourceVisitor(options, lineInfo, source, selection);
    node.accept(formatter);

    var formattedSource = formatter.writer.toString();

    checkTokenStreams(startToken, tokenize(formattedSource),
                      allowTransforms: options.codeTransforms);

    return new FormattedSource(formattedSource, formatter.selection);
  }
}

class StripSourceVisitor extends SourceVisitor {
  StripSourceVisitor(options, lineInfo, source, preSelection): super(options, lineInfo, source, preSelection);
}

