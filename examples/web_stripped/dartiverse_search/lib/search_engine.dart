// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library search_engine;

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:io' show HttpStatus;
import 'package:http/http.dart' as http_client;

part 'github_search_engine.dart';
part 'stack_overflow_search_engine.dart';


/**
 * A [SearchEngine] provides the ability to search for a given string.
 */
abstract class SearchEngine {



  get name;





  search(input);
}


/**
 * A [SearchResult] entry, returned by [SearchEngine.search].
 */
class SearchResult {
  /**
   * The title of the result.
   */
  final title;

  /**
   * The link of the result.
   */
  final link;

  /**
   * Create a new [SearchResult] from a title and a link.
   */
  SearchResult(this.title, this.link);
}

