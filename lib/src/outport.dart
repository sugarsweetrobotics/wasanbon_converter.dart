part of wasanbon_converter;

class OutPort extends PortBase {

  var _manager = null;
  set manager(var m) => _manager = m;

  OutPort(String name, dynamic dataBuffer) : super(name, dataBuffer) {
  }


  void write() {
    if (_manager != null) {
      _manager.writeOutPort(this);
    }
  }


  String toString() {
    return 'OutPort(name=$name, dataBuffer=$dataBuffer)';
  }
}