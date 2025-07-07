import 'package:flutter/material.dart';
import '../floating/assist/floating_slide_type.dart';
import '../floating/floating.dart';

class InternalFloatingPage extends StatefulWidget {
  const InternalFloatingPage({Key? key}) : super(key: key);

  @override
  State<InternalFloatingPage> createState() => _InternalFloatingPageState();
}

class _InternalFloatingPageState extends State<InternalFloatingPage> {
  var floating = Floating(
      Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      ),
      slideType: FloatingSlideType.onRightAndBottom,
      isShowLog: false,
      isSnapToEdge: true,
      isPosCache: true,
      moveOpacity: 1,
      left: 100,
      bottom: 100,
      slideBottomHeight: 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [floating.getFloating()],
      ),
    );
  }
}
