import 'package:flutter/material.dart';

/// @name：floating_icon
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/06/02 17:50
/// @des：

class FloatingIcon extends StatelessWidget {
  const FloatingIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amberAccent,
      child: const Icon(Icons.add_photo_alternate, size: 70),
    );
  }
}
