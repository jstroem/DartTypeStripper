#!/usr/bin/env dart

import 'dart:io';
import 'dart:math';
import 'package:analyzer/src/services/formatter_impl.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/scanner.dart';
import 'package:path/path.dart';
import 'package:args/args.dart';


bool STRIP_METHOD_SIG = true;
bool KEEP_GENERIC_TYPES = false;
String OVERRIDE_FILE = null;

main(List<String> args) {
  ArgParser argParser = new ArgParser();
  argParser ..addFlag('partial', help: "If set don't strip the method signatures.", abbr: 'p', defaultsTo: false, negatable: false)
            ..addFlag('strip-generics', help: "If set strips generic types.",  abbr: 'g', defaultsTo: false, negatable: false)
            ..addFlag('override', help: "If set, overrides the files with the stripped version", abbr: 'w', defaultsTo: false, negatable: false);
            
  ArgResults results = argParser.parse(args);

  List<String> files = results.rest;
  STRIP_METHOD_SIG = !results['partial'];
  KEEP_GENERIC_TYPES = !results['strip-generics'];
  
  for (String arg in files) {
    CodeFormatterImpl cf = new StripCodeFormatterImpl(const FormatterOptions());
    CodeFormatter finisher = new CodeFormatter();
    File file = new File(arg);
    var src = file.readAsStringSync();
    
    
    FormattedSource fs = cf.format(CodeKind.COMPILATION_UNIT, src);


    
    fs = finisher.format(CodeKind.COMPILATION_UNIT, fs.source);
    if (results['override'])
      file.writeAsStringSync(fs.source);
    else
      print(fs.source);
  }
}

class StripCodeFormatterImpl extends CodeFormatterImpl {
  
  
  StripCodeFormatterImpl(options):super(options);
  
  
  FormattedSource format(CodeKind kind, String source, {int offset, int end,
      int indentationLevel: 0, Selection selection: null}) {

    var startToken = tokenize(source);
    checkForErrors();

    var node = parse(kind, startToken);
    checkForErrors();

    var t = node.toString();
    
    var formatter = new StripSourceVisitor(options, lineInfo, source, selection);
    node.accept(formatter);

    var formattedSource = formatter.writer.toString();

    return new FormattedSource(formattedSource, formatter.selection);
  }
}

class StripSourceVisitor extends SourceVisitor {
  StripSourceVisitor(options, lineInfo, source, preSelection): super(options, lineInfo, source, preSelection);
  
  List<String> typeArguments = new List<String>();
  
  bool printTokens = true;
  
  token(Token token, {precededBy(), followedBy(), printToken(tok),
      int minNewlines: 0}) {
    if (token != null) {
      if (needsNewline) {
        minNewlines = max(1, minNewlines);
      }
      var emitted = emitPrecedingCommentsAndNewlines(token, min: minNewlines);
      if (emitted > 0) {
        needsNewline = false;
      }
      if (precededBy != null) {
        precededBy();
      }
      checkForSelectionUpdate(token);
      if (printTokens) {
        if (printToken == null) {
          append(token.lexeme);
        } else {
          printToken(token);
        }
      }   
      if (followedBy != null) {
        followedBy();
      }
      previousToken = token;
    }
  }
  
  visitClassDeclaration(ClassDeclaration node) {
    
      typeArguments.clear();
      if (node.typeParameters != null)
        node.typeParameters.typeParameters.forEach((TypeParameter ty) => typeArguments.add(ty.name.toString()));
    
      preserveLeadingNewlines();
      visitMemberMetadata(node.metadata);
      modifier(node.abstractKeyword);
      token(node.classKeyword);
      space();
      visit(node.name);
      allowContinuedLines((){
        visit(node.typeParameters);
        visitNode(node.extendsClause, precededBy: space);
        visitNode(node.withClause, precededBy: space);
        visitNode(node.implementsClause, precededBy: space);
        visitNode(node.nativeClause, precededBy: space);
        space();
      });
      token(node.leftBracket);
      indent();
      if (!node.members.isEmpty) {
        visitNodes(node.members, precededBy: newlines, separatedBy: newlines);
        newlines();
      } else {
        preserveLeadingNewlines();
      }
      token(node.rightBracket, precededBy: unindent);
    } 
  
  
  visitSimpleFormalParameter(SimpleFormalParameter node) {
     visitMemberMetadata(node.metadata);
     modifier(node.keyword);
     
     //Only print formal argument types if doing partial strip 
     
     bool isGenericType = (node.type != null && typeArguments.contains(node.type.name.toString()));     
     if (!STRIP_METHOD_SIG || (isGenericType && KEEP_GENERIC_TYPES)) visitNode(node.type, followedBy: nonBreakingSpace);
    
     visit(node.identifier);
   }

  visitFunctionDeclaration(FunctionDeclaration node) {

    preserveLeadingNewlines();
    visitMemberMetadata(node.metadata);
    modifier(node.externalKeyword);
    
    //Only print formal argument types if doing partial strip 
    if (STRIP_METHOD_SIG) printTokens = false;      
    visitNode(node.returnType, followedBy: space);
    printTokens = true;

    
    modifier(node.propertyKeyword);
    visit(node.name);
    visit(node.functionExpression);
  }

  
  
  visitVariableDeclarationList(VariableDeclarationList node) {
    
    bool isGenericType = (node.type != null && typeArguments.contains(node.type.name.toString()));
    
    visitMemberMetadata(node.metadata);
    modifier(node.keyword);
    
    if (!(isGenericType && KEEP_GENERIC_TYPES)) printTokens = false;

    visitNode(node.type, followedBy: space);
    printTokens = true;
      
    
    if (!(isGenericType && KEEP_GENERIC_TYPES) && node.type != null && node.keyword == null) {
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
      
      //Here the return types are printed so we don't write anything out.
      bool isGenericType = (node.returnType != null && typeArguments.contains(node.returnType.name.toString()));     
      if (!STRIP_METHOD_SIG ||(isGenericType && KEEP_GENERIC_TYPES)) visitNode(node.returnType, followedBy: space);
      
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
    bool isGenericType = (node.returnType != null && typeArguments.contains(node.returnType.name.toString()));
    if (!STRIP_METHOD_SIG || (isGenericType && KEEP_GENERIC_TYPES))
      visitNode(node.returnType, followedBy: space);
    visit(node.identifier);
    visit(node.parameters);
  }
  
  //FieldFormalParameter is the used for the special syntax in dart, where you can shorthand assigning an argument directly to a field of the instance.
  //eg MyConstructor(this.SomeField)  
  visitFieldFormalParameter(FieldFormalParameter node) {
    token(node.keyword, followedBy: space);
    //If a field is set using formal parameters we strip the type.
    bool isGenericType = (node.type != null && typeArguments.contains(node.type.name.toString()));
    if (!STRIP_METHOD_SIG || (isGenericType && KEEP_GENERIC_TYPES))
      visitNode(node.type, followedBy: space);

    token(node.thisToken);
    token(node.period);
    visit(node.identifier);
    visit(node.parameters);
  }

  visitDeclaredIdentifier(DeclaredIdentifier node) {
    modifier(node.keyword);
    //In for loops if there is a type used in the variable decl, we put a 'var' in instead. 
    bool isGenericType = (node.type != null && typeArguments.contains(node.type.name.toString()));
    
    if (isGenericType && KEEP_GENERIC_TYPES) {
      visitNode(node.type, followedBy: space);  
    } else if (node.type != null && node.keyword == null) {
      Identifier ident = new SimpleIdentifier(new KeywordToken(Keyword.VAR, node.type.offset));
      visitNode(ident, followedBy: space);
    }
    visit(node.identifier);
  }
}

