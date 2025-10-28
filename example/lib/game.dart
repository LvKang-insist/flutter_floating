import 'package:flutter/material.dart';
import 'dart:math';
import "package:vector_math/vector_math_64.dart" show Vector3;

enum Direction {
  center,
  up,
  down,
  left,
  right,
  upLeft,
  upRight,
  downLeft,
  downRight,
}

typedef DirectionCallback = VoidCallback?;

class GameControllerWidget extends StatelessWidget {
  final double size; // 控件整体宽高
  final double buttonSize; // 单个按键建议大小（可小于单元格）
  final Color color;
  final Color highlightColor;

  // 每个方向的回调（可为 null）
  final DirectionCallback onCenter;
  final DirectionCallback onUp;
  final DirectionCallback onDown;
  final DirectionCallback onLeft;
  final DirectionCallback onRight;
  final DirectionCallback onUpLeft;
  final DirectionCallback onUpRight;
  final DirectionCallback onDownLeft;
  final DirectionCallback onDownRight;

  const GameControllerWidget({
    super.key,
    this.size = 200,
    this.buttonSize = 56,
    this.color = const Color(0xFF444444),
    this.highlightColor = const Color(0xFF888888),
    this.onCenter,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
    this.onUpLeft,
    this.onUpRight,
    this.onDownLeft,
    this.onDownRight,
  });

  Widget _cell(Direction dir, DirectionCallback cb) {
    return Center(
      child: DirectionButton(
        size: buttonSize,
        color: color,
        highlightColor: highlightColor,
        direction: dir,
        onTap: cb,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cell = size / 3;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        children: [
          SizedBox(
            height: cell,
            child: Row(
              children: [
                SizedBox(width: cell, child: _cell(Direction.upLeft, onUpLeft)),
                SizedBox(width: cell, child: _cell(Direction.up, onUp)),
                SizedBox(width: cell, child: _cell(Direction.upRight, onUpRight)),
              ],
            ),
          ),
          SizedBox(
            height: cell,
            child: Row(
              children: [
                SizedBox(width: cell, child: _cell(Direction.left, onLeft)),
                SizedBox(width: cell, child: _cell(Direction.center, onCenter)),
                SizedBox(width: cell, child: _cell(Direction.right, onRight)),
              ],
            ),
          ),
          SizedBox(
            height: cell,
            child: Row(
              children: [
                SizedBox(width: cell, child: _cell(Direction.downLeft, onDownLeft)),
                SizedBox(width: cell, child: _cell(Direction.down, onDown)),
                SizedBox(width: cell, child: _cell(Direction.downRight, onDownRight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DirectionButton extends StatefulWidget {
  final double size;
  final Color color;
  final Color highlightColor;
  final Direction direction;
  final VoidCallback? onTap;

  const DirectionButton({
    super.key,
    required this.size,
    required this.color,
    required this.highlightColor,
    required this.direction,
    this.onTap,
  });

  @override
  State<DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<DirectionButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap?.call();
      },
      onTapCancel: () => _setPressed(false),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ButtonPainter(
            color: _pressed ? widget.highlightColor : widget.color,
            direction: widget.direction,
          ),
        ),
      ),
    );
  }
}

class _ButtonPainter extends CustomPainter {
  final Color color;
  final Direction direction;

  _ButtonPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);

    if (direction == Direction.center) {
      // 中心圆
      final r = min(size.width, size.height) * 0.4;
      canvas.drawCircle(center, r, paint);
      // 画一个小圆环作为视觉
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, r * 0.12)
        ..color = color.withAlpha((0.6 * 255).round());
      canvas.drawCircle(center, r + r * 0.08, ring);
      return;
    }

    // 其他方向：绘制三角指向箭头
    final path = Path();
    // 基础等边三角形向上，中心在中心点
    final double r = min(size.width, size.height) * 0.42;
    final p1 = Offset(center.dx, center.dy - r); // top
    final p2 = Offset(center.dx - r * 0.85, center.dy + r * 0.6); // bottom-left
    final p3 = Offset(center.dx + r * 0.85, center.dy + r * 0.6); // bottom-right
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();

    // 根据 direction 旋转 path 到目标方向
    double angle = 0;
    switch (direction) {
      case Direction.up:
        angle = 0;
        break;
      case Direction.upRight:
        angle = pi / 4;
        break;
      case Direction.right:
        angle = pi / 2;
        break;
      case Direction.downRight:
        angle = 3 * pi / 4;
        break;
      case Direction.down:
        angle = pi;
        break;
      case Direction.downLeft:
        angle = -3 * pi / 4;
        break;
      case Direction.left:
        angle = -pi / 2;
        break;
      case Direction.upLeft:
        angle = -pi / 4;
        break;
      case Direction.center:
        angle = 0;
        break;
    }

    // 旋转 path
    final Matrix4 m = Matrix4.identity()
      ..translateByVector3(Vector3(center.dx, center.dy, 0))
      ..rotateZ(angle)
      ..translateByVector3(Vector3(-center.dx, -center.dy, 0));
    final rotated = path.transform(m.storage);

    canvas.drawPath(rotated, paint);

    // 添加内阴影（简易）
    final shadow = Paint()
      ..color = Colors.black.withAlpha((0.15 * 255).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(rotated.shift(const Offset(0, 1)), shadow);
  }

  @override
  bool shouldRepaint(covariant _ButtonPainter old) {
    return old.color != color || old.direction != direction;
  }
}
