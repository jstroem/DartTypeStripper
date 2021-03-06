// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of search_engine;


class StackOverflowSearchEngine implements SearchEngine {
  get name => 'StackOverflow';

  search(input) {
    var query = {
      'site': 'stackoverflow',
      'tagged': 'dart',
      'intitle': input,
      'sort': 'relevance',
      'order': 'desc',
      'pagesize': '3'
    };
    var searchUri = new Uri.http('api.stackexchange.com', '/2.1/search', query);
    var controller = new StreamController();
    http_client.get(searchUri).then((response) {
      if (response.statusCode != HttpStatus.OK) {
        throw "Bad status code: ${response.statusCode}, "
            "message: ${response.reasonPhrase}";
      }
      var json = JSON.decode(response.body);
      json.putIfAbsent('items', () => []);
      json['items'].take(3).forEach((item) {
        controller.add(new SearchResult(item['title'], item['link']));
      });
    }).catchError(controller.addError).whenComplete(controller.close);
    return controller.stream;
  }
}

