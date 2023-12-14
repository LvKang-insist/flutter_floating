import 'package:flutter/material.dart';

/// @name：button_widget
/// @package：widget
/// @author：345 QQ:1831712732
/// @time：2021/05/11 11:19
/// @des：
///
class ButtonWidget extends StatefulWidget {
  final Function callback;
  final EdgeInsets? margin;
  final String text;
  final double? height;
  final Color? background;
  final FontWeight? fontWeight;

   const ButtonWidget(this.text, this.callback,
      {this.margin,
      this.height,
      this.background = Colors.blue,
      this.fontWeight,
      Key? key})
      : super(key: key);

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget>  with TickerProviderStateMixin {
  /// 动画控制器，设置动画持续时间为5秒，可重复播放
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      child: InkWell(
        child: Container(
          child: Text(widget.text,
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight:widget. fontWeight)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4), color: widget.background),
          width: double.infinity,
          alignment: Alignment.center,
          height: 44,
        ),
        onTap: () => widget.callback(),
      ),
    );
  }
}
