import 'package:flutter/material.dart';

/// @name：button_widget
/// @package：widget
/// @author：345 QQ:1831712732
/// @time：2021/05/11 11:19
/// @des：
///
class ButtonWidget extends StatelessWidget {
  final Function callback;
  final EdgeInsets? margin;
  final String text;
  final double? height;
  final Color? background;
  final FontWeight? fontWeight;

  const ButtonWidget(this.text, this.callback,
      {this.margin, this.height, this.background = Colors.blue, this.fontWeight, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      height: height ?? 44,
      child: InkWell(
        child: Container(
          child: Text(text,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: fontWeight)),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: background),
          width: double.infinity,
          alignment: Alignment.center,
          height: 44,
        ),
        onTap: () => callback(),
      ),
    );
  }
}
