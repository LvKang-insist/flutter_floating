import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/assist/floating_common_params.dart';
import 'package:flutter_floating/floating/assist/floating_edge_type.dart';
import 'package:flutter_floating/floating/floating_overlay.dart';


///页面内使用
class InternalFloatingPage extends StatefulWidget {
  const InternalFloatingPage({super.key});

  @override
  State<InternalFloatingPage> createState() => _InternalFloatingPageState();
}

class _InternalFloatingPageState extends State<InternalFloatingPage> {
  var floating = FloatingOverlay(
    Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    ),
    slideType: FloatingEdgeType.onRightAndBottom,
    params: FloatingParams(
      isShowLog: false,
      isSnapToEdge: true,
      enablePositionCache: true,
      dragOpacity: 1,
      marginBottom: 100,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [floating.getFloating()],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    floating.dispose();
  }
}
