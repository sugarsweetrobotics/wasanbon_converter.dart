library wasanbon_converter.ws_test;

import 'dart:core';
import 'dart:html';

import 'package:wasanbon_converter/wasanbon_converter.dart';

main() {
  var webSocket = new WebSocket('ws://127.0.0.1:8080/ws');

  var data = 'Hello Dart WebScoket';

  if (webSocket != null && webSocket.readyState == WebSocket.OPEN) {
    webSocket.send(data);
  } else {
    print('WebSocket not connected, message $data not sent');
  }

  webSocket.onMessage.listen((MessageEvent e) {
    print('Message is $e');
  });
}
