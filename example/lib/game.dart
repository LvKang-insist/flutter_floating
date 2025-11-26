// dart
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

  // 为除 center 外增加的双击回调
  final DirectionCallback? onUpDoubleTap;
  final DirectionCallback? onDownDoubleTap;
  final DirectionCallback? onLeftDoubleTap;
  final DirectionCallback? onRightDoubleTap;
  final DirectionCallback? onUpLeftDoubleTap;
  final DirectionCallback? onUpRightDoubleTap;
  final DirectionCallback? onDownLeftDoubleTap;
  final DirectionCallback? onDownRightDoubleTap;

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
    this.onUpDoubleTap,
    this.onDownDoubleTap,
    this.onLeftDoubleTap,
    this.onRightDoubleTap,
    this.onUpLeftDoubleTap,
    this.onUpRightDoubleTap,
    this.onDownLeftDoubleTap,
    this.onDownRightDoubleTap,
  });

  Widget _cell(Direction dir, DirectionCallback cb, DirectionCallback? doubleTapCb) {
    return Center(
      child: DirectionButton(
        size: buttonSize,
        color: color,
        highlightColor: highlightColor,
        direction: dir,
        onTap: cb,
        onDoubleTap: doubleTapCb,
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
                SizedBox(width: cell, child: _cell(Direction.upLeft, onUpLeft, onUpLeftDoubleTap)),
                SizedBox(width: cell, child: _cell(Direction.up, onUp, onUpDoubleTap)),
                SizedBox(width: cell, child: _cell(Direction.upRight, onUpRight, onUpRightDoubleTap)),
              ],
            ),
          ),
          SizedBox(
            height: cell,
            child: Row(
              children: [
                SizedBox(width: cell, child: _cell(Direction.left, onLeft, onLeftDoubleTap)),
                SizedBox(width: cell, child: _cell(Direction.center, onCenter, null)), // center 无双击
                SizedBox(width: cell, child: _cell(Direction.right, onRight, onRightDoubleTap)),
              ],
            ),
          ),
          SizedBox(
            height: cell,
            child: Row(
              children: [
                SizedBox(width: cell, child: _cell(Direction.downLeft, onDownLeft, onDownLeftDoubleTap)),
                SizedBox(width: cell, child: _cell(Direction.down, onDown, onDownDoubleTap)),
                SizedBox(width: cell, child: _cell(Direction.downRight, onDownRight, onDownRightDoubleTap)),
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
  final VoidCallback? onDoubleTap;

  const DirectionButton({
    super.key,
    required this.size,
    required this.color,
    required this.highlightColor,
    required this.direction,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<DirectionButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    // update pressed state
    setState(() => _pressed = v);
    // When pressed, pause/stop the hint animation to reduce visual clutter.
    // When released, resume the animation only if the button supports double-tap.
    if (v) {
      if (_animController.isAnimating) _animController.stop();
    } else {
      if (widget.onDoubleTap != null && !_animController.isAnimating) {
        _animController.repeat();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Create a two-pulse animation to hint "double-tap"
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    // scale does two short pulses per cycle
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9).chain(CurveTween(curve: Curves.easeIn)), weight: 15),
      TweenSequenceItem(tween: ConstantTween(0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.18).chain(CurveTween(curve: Curves.easeOut)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
    ]).animate(_animController);

    // opacity pulses alongside scale to emphasize the double pulse
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6).chain(CurveTween(curve: Curves.easeIn)), weight: 15),
      TweenSequenceItem(tween: ConstantTween(0.6), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.95).chain(CurveTween(curve: Curves.easeOut)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 0.7).chain(CurveTween(curve: Curves.easeIn)), weight: 15),
      TweenSequenceItem(tween: ConstantTween(0.7), weight: 20),
    ]).animate(_animController);

    if (widget.onDoubleTap != null) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant DirectionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If double-tap availability changed, start/stop the animation accordingly.
    // Don't auto-start if the button is currently pressed (to avoid visual jump).
    if (oldWidget.onDoubleTap == null && widget.onDoubleTap != null) {
      if (!_pressed) _animController.repeat();
    } else if (oldWidget.onDoubleTap != null && widget.onDoubleTap == null) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
      // use double-tap for the new secondary action
      onDoubleTap: () {
        // visual feedback: briefly show pressed state
        _setPressed(true);
        // schedule releasing pressed state on next frame
        WidgetsBinding.instance.addPostFrameCallback((_) => _setPressed(false));
        widget.onDoubleTap?.call();
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        // Use a Stack so we can overlay a small long-press indicator when available
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: _ButtonPainter(
                color: _pressed ? widget.highlightColor : widget.color,
                direction: widget.direction,
              ),
              size: Size(widget.size, widget.size),
            ),
            // If this button supports double-tap, show a small animated '2×' indicator in the top-right
            if (widget.onDoubleTap != null)
              Positioned(
                top: max(2.0, widget.size * 0.06),
                right: max(2.0, widget.size * 0.06),
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: FadeTransition(
                    opacity: _opacityAnim,
                    child: Container(
                      width: widget.size * 0.22,
                      height: widget.size * 0.22,
                      decoration: BoxDecoration(
                        // avoid deprecated withOpacity; use withAlpha for a stable color value
                        color: Colors.black.withAlpha((0.6 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      // show '2×' to clearly indicate double-tap
                      child: Text(
                        '2×',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.size * 0.12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
