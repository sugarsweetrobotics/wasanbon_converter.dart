part of wasanbon_converter;


class RTC {

  List<OutPortBase> outPorts = [];

  List<InPortBase> inPorts = [];

  Map<String, String> properties = {};

  RTC() {
  }


  void addInPort(InPortBase inPort) {
    inPorts.add(inPort
     ..owner = this);
  }

  void addOutPort(OutPortBase outPort) {
    outPorts.add(outPort
      ..owner = this);
  }

}