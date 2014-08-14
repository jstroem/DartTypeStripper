#!/usr/bin/env dart

import 'dart:io';

import 'package:analyzer/src/services/formatter_impl.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/scanner.dart';


 bool STRIP_METHOD_SIG = true;

main(List<String> args) {
  //print('working dir ${new File('.').resolveSymbolicLinksSync()}');

  if (args.length == 0) {
    args = ["../examples/before.dart"];
  }

  List<String> files = new List<String>();
  
  for (String arg in args) {
    //Handle -Partial flag, such the method sigs are left as is
    if (arg == '-Partial' || arg == '-P') {
      STRIP_METHOD_SIG = false;
    } else {
      files.add(arg);
    }
  }
  
  for (String arg in files) {
    StripCodeFormatterImpl cf = new StripCodeFormatterImpl(const FormatterOptions());
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

    /*checkTokenStreams(startToken, tokenize(formattedSource),
                      allowTransforms: options.codeTransforms);*/

    return new FormattedSource(formattedSource, formatter.selection);
  }
}

class StripSourceVisitor extends SourceVisitor {
  StripSourceVisitor(options, lineInfo, source, preSelection): super(options, lineInfo, source, preSelection);
  
  @override
  visitSimpleFormalParameter(SimpleFormalParameter node) {
     visitMemberMetadata(node.metadata);
     modifier(node.keyword);
     
     //Only print formal argument types if doing partial strip 
     if (!STRIP_METHOD_SIG) visitNode(node.type, followedBy: nonBreakingSpace);
    
     visit(node.identifier);
   }

  @override
  visitFunctionDeclaration(FunctionDeclaration node) {
    preserveLeadingNewlines();
    visitMemberMetadata(node.metadata);
    modifier(node.externalKeyword);
    
    //Only print formal argument types if doing partial strip 
    if (!STRIP_METHOD_SIG) visitNode(node.returnType, followedBy: space);
   
    modifier(node.propertyKeyword);
    visit(node.name);
    visit(node.functionExpression);
  }

  @override
  visitVariableDeclarationList(VariableDeclarationList node) {
    visitMemberMetadata(node.metadata);
    modifier(node.keyword);
    //visitNode(node.type, followedBy: space); This is the type of the variables, so instead we put in 'var'
    if (node.type != null) {
      Identifier ident = new SimpleIdentifier(new KeywordToken(Keyword.VAR, node.type.offset));
      visitNode(ident, followedBy: space);
    }

    var variables = node.variables;
    // Decls with initializers get their own lines (dartbug.com/16849)
    if (variables.any((v) => (v.initializer != null))) {
      var size = variables.length;
      if (size > 0) {
        var variable;
        for (var i = 0; i < size; i++) {
          variable = variables[i];
          if (i > 0) {
            var comma = variable.beginToken.previous;
            token(comma);
            newlines();
          }
          if (i == 1) {
            indent(2);
          }
          variable.accept(this);
        }
        if (size > 1) {
          unindent(2);
        }
      }
    } else {
      visitCommaSeparatedNodes(node.variables);
    }
  }
  
  @override
  visitMethodDeclaration(MethodDeclaration node) {
      visitMemberMetadata(node.metadata);
      modifier(node.externalKeyword);
      modifier(node.modifierKeyword);
      //Here the return type are printed so we don't write anything out.
      if (!STRIP_METHOD_SIG) visitNode(node.returnType, followedBy: space);
      
      modifier(node.propertyKeyword);
      modifier(node.operatorKeyword);
      visit(node.name);
      if (!node.isGetter) {
        visit(node.parameters);
      }
      visitPrefixedBody(nonBreakingSpace, node.body);
    }
  
  @override
  visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    //If a method is used in the parameter list and it has a return type, we strip this.
    if (!STRIP_METHOD_SIG)
      visitNode(node.returnType, followedBy: space);
    visit(node.identifier);
    visit(node.parameters);
  }
}

