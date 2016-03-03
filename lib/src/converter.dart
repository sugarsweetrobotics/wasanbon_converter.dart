part of wasanbon_converter;


class DataPacket {

}

class Converter {


  logging.Logger logger;
  bool _test = false;

  var _ws;

  int _mode = 0;

  var _state = STATE_DISCONNECT;

  var _handshake_message = 'wasanbon_converter version="0.0.1"';
  var _handshake_response = 'wasanbon_converter ready';

  get ready => _state == STATE_READY;
  get connected => _state == STATE_CONNECT;
  get disconnected => _state == STATE_DISCONNECT;

  Converter({bool test: false}) {
    this._test = test;
    logger = new logging.Logger(this.runtimeType.toString());
  }

  bool connectIO(var webSocket) {
    this._ws = webSocket;
    _ws.listen(this._onMessage);
    _state = STATE_CONNECT;
    _ws.add('$_handshake_message test="$_test"');
    return true;
  }


  void sendMessage(String msg) {
    if (_mode == 0) {
      _ws.add(msg);
    } else {
      _ws.send(msg);
    }
  }

  async.Future connectHtml(var webSocket) {
    _mode = 1;
    var c = new async.Completer();
    this._ws = webSocket;
    _ws.on['open'].listen((var e) {
      _state = STATE_CONNECT;
      _ws.send("$_handshake_message test=$_test");
      c.complete(c);
    });
    _ws.onMessage.listen(this._onMessageEvent);
    return c.future;
  }

  bool disconnect() {
    _ws.close();
    _state = STATE_DISCONNECT;
    return false;
  }

  void _onMessageEvent(var e) {
    _onMessage(e.data);
  }

  async.StreamController<String> _onInPort = new async.StreamController<String>();
  async.Stream get onInPort => _onInPort.stream;

  void _onMessage(String data) {
    if (ready) {
      logger.fine(' in ready state, received $data');
      if (data.startsWith('InPort')) {
        _onInPort.add(data);
      }else if (_hooks != null) {
        var _hookedKey = null;
        _hooks.forEach((String _receiveStarts, async.Completer _hook) {
          if (data.startsWith(_receiveStarts)) {
            _hook.complete(data);
            _hookedKey = _receiveStarts;
          }
        });
        if (_hookedKey != null) {
          if (!_hookedKey.startsWith('_')) {
            _hooks.remove(_hookedKey);
          }
        }

      }
    } else if (connected) {
      if (data == _handshake_response) {
        _state = STATE_READY;
      }
    }
  }

  Map<String, async.Completer> _hooks = new Map<String, async.Completer>();

  async.Future<dynamic> send(String msg, String receiveStarts) {
    var _hook = new async.Completer();
    _hooks[receiveStarts] = _hook;
    sendMessage(msg);
    return _hook.future;
  }

  static const String STATE_DISCONNECT = 'disconnected';
  static const String STATE_CONNECT = 'connected';
  static const String STATE_READY = 'ready';


}