library wasanbon_converter.manager_test;

import 'dart:core';
//import 'dart:js';
import 'dart:io' as io;
import 'dart:async';
import 'package:logging/logging.dart';

import 'package:wasanbon_converter/wasanbon_converter.dart';

class Time {
  static const String typeCode = "RTC.Time";
  int sec;
  int nsec;


  Time.zeros() {
    sec = 0;
    nsec = 0;
  }


  Time( int sec_, int nsec_) {
    sec = sec_;
    nsec = nsec_;
  }

  List<String> serialize() {
    var ls = [];
    ls.add(nsec.toString());
    ls.add(sec.toString());
    return ls;
  }

  int parse(List<String> ls) {
    int index = 0;
    nsec = num.parse(ls[index]);
    index++;
    sec = num.parse(ls[index]);
    index++;
    return index;
  }

  String toString() {
    String ret = "Time(";
    ret += "nsec = $nsec";
    ret += ", ";
    ret += "sec = $sec";
    return ret + ")";
  }

}



class TimedLong {
  String typeCode = "RTC.TimedLong";
  Time tm;
  int data;


  TimedLong.zeros() {
    tm = new Time.zeros();
    data = 0;
  }


  TimedLong( Time tm_, int data_) {
    tm = tm_;
    data = data_;
  }

  List<String> serialize() {
    var ls = [];
    ls.add(data.toString());
    ls.addAll(tm.serialize());
    return ls;
  }

  int parse(List<String> ls) {
    int index = 0;
    data = num.parse(ls[index]);
    index++;
    index += tm.parse(ls.sublist(index));
    return index;
  }

  String toString() {
    String ret = "TimedLong(";
    ret += "data = $data";
    ret += ", ";
    ret += "tm = $tm";
    return ret + ")";
  }

}




main() {
  Logger.root.level = Level.ALL;
  Manager m = new Manager();// = new Converter(test: true);

  m.onRecordListen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  io.WebSocket.connect('ws://127.0.0.1:8080/ws').then((io.WebSocket s) {
    m.connectIO(s);

    /// ポートの追加
    //m.addInPort('in', new TimedLong.zeros()).then((bool flag) {
    InPort inIn = new InPort('in', new TimedLong.zeros());
    m.addInPort(inIn).then((bool flag) {
      inIn.on.listen((var data) {
        print('InPort received $data');
      });

    });

    var out = new TimedLong.zeros();
    OutPort outOut = new OutPort('out', out);
    m.addOutPort(outOut);

    for(int i = 0;i < 50;i++) {
      new Future.delayed(new Duration(seconds: 3*i)).then((_) {
        out.data = i * 10;
        out.tm.sec = i;
        out.tm.nsec = 0;
        outOut.write();
      });
    }


    new Future.delayed(new Duration(seconds:300)).then((_) {
      m.disconnect();
    });

  });
}
