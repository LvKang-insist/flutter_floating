/// @name：play_floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/03/27 14:44
/// @des：
import 'package:flutter/material.dart';
import 'package:flutter_floating/page.dart';

class FloatingPlay extends StatelessWidget {
  const FloatingPlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const CustomPage();
          }));
        },
        child: child(size),
      ),
    );
  }

  Widget child(Size size) {
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0, 0),
          blurRadius: 16,
        )
      ]),
      child: StreamBuilder<String>(builder: (context, snapshot) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      child:
                          Container(color: Colors.grey, width: 56, height: 32)),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(4, 3, 4, 3),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        "哈哈红红火火恍恍惚惚",
                        style: TextStyle(fontSize: 8, color: Colors.amber),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Expanded(
                child: SizedBox(
              height: 22,
              child: Text('欢迎使用一键式悬浮窗组件',
                style: TextStyle(fontSize: 15, color: Colors.redAccent),
              ),
            )),
            StreamBuilder<String>(builder: (context, snapshot) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Container(
                  height: 32,
                  width: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.purple,
                ),
              );
            }),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  color: Colors.pink,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  color: Colors.yellow,
                  width: 24,
                  height: 24,
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
