part of wasanbon_converter;



class InPort extends PortBase {

  async.StreamController<dynamic> _streamController = new async.StreamController<dynamic>();

  async.StreamController<dynamic> get streamController => _streamController;
  async.Stream get on => streamController.stream;


  InPort(String name, dynamic dataBuffer) : super(name, dataBuffer) {
  }

  String toString() {
    return 'InPort(name=$name, dataBuffer=$dataBuffer)';
  }
}