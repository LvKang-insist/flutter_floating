import 'package:flutter/cupertino.dart';

/// @name：test
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/11 11:06
/// @des：

class Box extends StatefulWidget {
  final Color color;

  const Box(this.color, { Key? key}) : super(key: key);

  @override
  _BoxState createState() => _BoxState();
}
class _BoxState extends State<Box> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          width: 100,
          height: 100,
          color: widget.color,
          alignment: Alignment.center,
          child: Text(_count.toString(), style: TextStyle(fontSize: 30))),
      onTap: () => setState(() => ++_count),
    );
  }
}
