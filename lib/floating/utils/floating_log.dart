import 'package:flutter/foundation.dart';

/// @name：log
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/14 21:57
/// @des：

class FloatingLog {
  FloatingLog(bool isShowLog,String logKey) {
    init(isShowLog,logKey);
  }

  static const _separator = "=";
  static const _split =
      "$_separator$_separator$_separator$_separator$_separator$_separator$_separator$_separator$_separator";
  static const _title = "Floating_Log";
  static const int _limitLength = 800;
  static String _startLine = "$_split$_title$_split";
  bool isShowLog = false;
  String logKey = "";

  void init(bool isShowLog, String logKey) {
    this.isShowLog = isShowLog;
    this.logKey = logKey;
    _startLine = "$_split$_title$_split";
    var endLineStr = StringBuffer();
    var cnCharReg = RegExp("[\u4e00-\u9fa5]");
    for (int i = 0; i < _startLine.length; i++) {
      if (cnCharReg.stringMatch(_startLine[i]) != null) {
        endLineStr.write(_separator);
      }
      endLineStr.write(_separator);
    }
  }

  log(dynamic obj) {
    if (!isShowLog) return;
    if (obj.toString().length < _limitLength) {
      _log(obj.toString());
    } else {
      _splitLog(obj);
    }
  }

  void _log(String msg) {
    debugPrint("$_title $logKey ： $msg");
  }

  void _splitLog(String msg) {
    var outStr = StringBuffer();
    _log("");
    for (var index = 0; index < msg.length; index++) {
      outStr.write(msg[index]);
      if (index % _limitLength == 0 && index != 0) {
        debugPrint(outStr.toString());
        outStr.clear();
        var lastIndex = index + 1;
        if (msg.length - lastIndex < _limitLength) {
          var remainderStr = msg.substring(lastIndex, msg.length);
          debugPrint(remainderStr);
          break;
        }
      }
    }
  }
}
