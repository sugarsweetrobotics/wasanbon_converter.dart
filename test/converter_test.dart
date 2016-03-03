library wasanbon_converter.converter_test;

import 'dart:core';
import 'dart:io' as io;
import 'dart:async';
import 'package:logging/logging.dart';

import 'package:wasanbon_converter/wasanbon_converter.dart';

main() {
  Logger.root.level = Level.ALL;
  Converter c = new Converter(test: true);

  c.logger.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  io.WebSocket.connect('ws://127.0.0.1:8080/ws').then((io.WebSocket s) {
    c.connectIO(s);

    new Future.delayed(new Duration(seconds:3)).then((_) {
      c.disconnect();
    });

  });
}
