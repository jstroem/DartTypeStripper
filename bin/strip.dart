#!/usr/bin/env dart

import 'dart:io';
import 'package:analyzer/src/services/formatter_impl.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/scanner.dart';
import 'package:path/path.dart';


 bool STRIP_METHOD_SIG = true;
 String OUTPUT_DIR = null;

main(List<String> args) {
  if (args.length == 0) {
    args = ["../examples/before.dart"];
  }

  List<String> files = new List<String>();
  
  for (var i = 0; i < args.length; i++){
    String arg = args[i];
    if (arg == '--partial' || arg == '-p') {
      STRIP_METHOD_SIG = false;
    } else if (arg == '-o' || arg == '--output') {
      OUTPUT_DIR = args[++i];
    } else {
      files.add(arg);
    }
  }
  
  Directory dir = null;
  if (OUTPUT_DIR != null) dir = new Directory(OUTPUT_DIR);
  
  for (String arg in files) {
    StripCodeFormatterImpl cf = new StripCodeFormatterImpl(const FormatterOptions());
    CodeFormatter finisher = new CodeFormatter();
    File file = new File(arg);
    var src = file.readAsStringSync();
    FormattedSource fs = cf.format(CodeKind.COMPILATION_UNIT, src);
    fs = finisher.format(CodeKind.COMPILATION_UNIT, fs.source);
    if (dir != null){
      new File(dir.absolute.path + Platform.pathSeparator + basename(file.path)).writeAsStringSync(fs.source);  
    } else {
      print(fs.source);
    }
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
  
  visitSimpleFormalParameter(SimpleFormalParameter node) {
     visitMemberMetadata(node.metadata);
     modifier(node.keyword);
     
     //Only print formal argument types if doing partial strip 
     if (!STRIP_METHOD_SIG) visitNode(node.type, followedBy: nonBreakingSpace);
    
     visit(node.identifier);
   }

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

  visitVariableDeclarationList(VariableDeclarationList node) {
    visitMemberMetadata(node.metadata);
    modifier(node.keyword);
    //visitNode(node.type, followedBy: space); This is the type of the variables, so instead we put in 'var'
    if (node.type != null && node.keyword == null) {
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
  
  visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    //If a method is used in the parameter list and it has a return type, we strip this.
    if (!STRIP_METHOD_SIG)
      visitNode(node.returnType, followedBy: space);
    visit(node.identifier);
    visit(node.parameters);
  }
  

  visitFieldFormalParameter(FieldFormalParameter node) {
    token(node.keyword, followedBy: space);
    //If a field is set using formal parameters we strip the type.
    if (!STRIP_METHOD_SIG)
      visitNode(node.type, followedBy: space);
    
    token(node.thisToken);
    token(node.period);
    visit(node.identifier);
    visit(node.parameters);
  }

  visitDeclaredIdentifier(DeclaredIdentifier node) {
    modifier(node.keyword);
    //In for loops if there is a type used in the variable decl, we put a 'var' in instead. 
    //visitNode(node.type, followedBy: space);
    if (node.type != null) {
      Identifier ident = new SimpleIdentifier(new KeywordToken(Keyword.VAR, node.type.offset));
      visitNode(ident, followedBy: space);
    }
    visit(node.identifier);
  }
}

