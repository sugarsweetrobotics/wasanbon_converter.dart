part of wasanbon_converter;


class Manager {

  Converter converter;
  logging.Logger logger;

  Map<String, InPort> _inPorts = {};

  Map<String, OutPort> _outPorts = {};

  Manager() {
    converter = new Converter(test: true);
    converter.onInPort.listen(onInPort);
    logger = new logging.Logger(this.runtimeType.toString());
  }

  onRecordListen(func) {
    converter.logger.onRecord.listen(func);
  }

  connectIO(ws) {
    return converter.connectIO(ws);
  }

  connectHtml(ws) {
    return converter.connectHtml(ws);
  }

  disconnect() {
    return converter.disconnect();
  }

  void onInPort(String data) {
    String body = data.substring('InPort'.length + 1).trim();
    Map<String, List<dynamic>> dic = convert.JSON.decode(body);
    var name = dic.keys.toList()[0];
    var value = dic[name];
    InPort ip = _inPorts[name];
    if (ip != null) {
      ip.dataBuffer.parse(value);
      ip.streamController.add(ip.dataBuffer);
    }
  }

  void writeOutPort(OutPort port) {
    String message = 'OutPort {"${port.name}": ${convert.JSON.encode(port.dataBuffer.serialize())}}';
    converter.sendMessage(message);
  }

  async.Future<bool> addInPort(InPort inPort) {
    logger.fine('Manager.addInPort($inPort) called.');
    async.Completer c = new async.Completer();
    var typeCode = inPort.dataBuffer.typeCode;
    var msg = 'manager addInPort ${inPort.name} ${typeCode.replaceAll('.', '::')}';
    const String recv = 'wsconverter addInPort';
    converter.send(msg, recv).then((String msg) {
      bool success = msg.substring(recv.length+1).trim() == 'true';
      if (success) {
        logger.info('Manager.addInPort($inPort) Succeeded.');
        _inPorts[inPort.name] = inPort;//.add(inPort);
        //inPortDataBuffers[inPort.name] = dataBuffer;
        //inPorts[name] = new async.StreamController<dynamic>();
      } else {
        logger.error('Manager.addInPort(${inPort}) Failed.');
      }
      c.complete(success);
    });
    return c.future;
  }


  async.Future<bool> addOutPort(OutPort outPort) {
    logger.fine('Manager.addOutPort($outPort) called.');
    async.Completer c = new async.Completer();
    var typeCode = outPort.dataBuffer.typeCode;
    var msg = 'manager addOutPort ${outPort.name} ${typeCode.replaceAll('.', '::')}';
    const String recv = 'wsconverter addOutPort';
    converter.send(msg, recv).then((String msg) {
      String output = msg.substring(recv.length+1).trim();
      bool success = output == 'true';
      if (success) {
        logger.info('Manager.addOutPort($outPort) Succeeded.');
        _outPorts[outPort.name] = outPort;
        outPort.manager = this;
      } else {
        logger.error('Manager.addOutPort(${outPort}) Failed.');
      }
      c.complete(success);
    });
    return c.future;
  }


  removeInPort(String name, String typename) {

  }

  removeOutPort(String name, String typename) {

  }
}