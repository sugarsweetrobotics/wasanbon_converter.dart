library wasanbon_converter.converter_test;

import 'dart:core';
import 'dart:html' as html;
import 'dart:async';

import 'package:wasanbon_converter/wasanbon_converter.dart';

main() {
  Converter c = new Converter();
  c.connectHtml(new html.WebSocket('ws://127.0.0.1:8080/ws')).then((_) {
    new Future.delayed(new Duration(seconds:3)).then((_) {
      c.disconnect();
    });

  });
}
