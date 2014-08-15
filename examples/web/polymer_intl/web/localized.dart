// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

/// This is an example polymer component that displays a message in one of
/// a couple of different locales, based on the user's drop-down list
/// selection.
@CustomTag('localized-example')
class LocalizedExampleElement extends PolymerElement {

  // Polymer likes to use observable variables and doesn't really like
  // observing getters, requiring us to do explicit notification when the
  // values that the getter depends on change. So we will save the result
  // of the message function in an observable variable. That will get
  // a bit trickier if we have messages that have parameters.
  @observable String selectedLocale;
  @observable String helloWorld;

  // It would be simpler to set [helloWorld] in an initializer, but we can't
  // put a method call in an initializer, so do it in the constructor.
  LocalizedExampleElement.created() : super.created() {
    updateLocale(Intl.defaultLocale);
  }

  // Polymer should call this method automatically if the value of
  // [selectedLocale] changes.
  void selectedLocaleChanged() {
    // We didn't provide en_US translations. We expect it to use the default
    // text in the messages for en_US. But then we have to not try and
    // initialize messages for the en_US locale. dartbug.com/15444
    if (selectedLocale == 'en_US') {
      updateLocale('en_US');
      return;
    }
    // For the normal case we initialize the messages, wait for initialization
    // to complete, then update all (all 1 of) our messages.
    initializeMessages(selectedLocale).then(
        (succeeded) => updateLocale(selectedLocale));
  }

  // When the user chooses a new locale, set the default locale for the
  // whole program to that and update our messages. In a large program this
  // could get to be a large method. Also, other components might want to
  // observe the default locale and update accordingly.
  void updateLocale(localeName) {
    Intl.defaultLocale = selectedLocale;
    helloWorld = helloFromDart();
  }

  // This is our message, a function that would take parameters if we have any
  // and then gives us back the appropriate translated message.
  // Of course, in order to make this happen we need to extract the messages
  // from our program. We don't have an integration with a real translation
  // system, but you can produce some custom JSON by running (assuming you have
  // the full Intl package available somewhere, like in a built SDK).
  //      dart --package-root=<some-path-to-packages>
  //          <path-to-intl>/intl/test/message_extraction/extract_to_json.dart
  //          localized.dart
  // That will produce intl_messages.json. We can then use whatever process
  // we want to produce translation_fr.json and translation_pt.json. I used
  // hand-editing, but that doesn't scale. Then
  //      dart --package-root=<some-path-to-packages>
  //          <path-to-intl>/intl/test/message_extraction/generate_from_json.dart
  //          localized.dart translation_fr.json translation_pt.json
  // will produce messages_all.dart, messages_fr.dart and messages_pt.dart.
  // We import messages_all.dart, and we're done.
  helloFromDart() => Intl.message("Hello World from Dart!", name: 'helloWorld',
      desc: "This is just a simple Hello World message that doesn't"
        "take any parameters.",
      args: [], // This would be required if we had any arguments.
      examples: {"We could put examples of parameter values here for the "
        "translators if we had any parameters" : 0});
}