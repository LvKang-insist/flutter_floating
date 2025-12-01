## 常见问题
1, 在 TabBarView 的 Page 中进行单页面使用时，在左右滑动悬浮窗时可能会和TabBarView的切换Page冲突

解决方式：
```dart
bool _isDragging = false;

TabBarView(
  controller: _tabController,
  //关键
  physics: _isDragging ? const NeverScrollableScrollPhysics() : null,
  children: [
    //page1
    Stack(
      children: [
        const AkDDHomeTabHot(),
        GestureDetector(
          onPanDown: (details) {
            // 用户按下时立即禁用 TabBarView 滑动
            setState(() {
            _isDragging = true;
            });
          },
          onPanUpdate: (details) {
            // 用户拖动时保持禁用状态
            setState(() {
            _isDragging = true;
            });
          },
          onPanEnd: (details) {
            // 用户拖动结束时恢复 TabBarView 滑动
            setState(() {
            _isDragging = false;
            });
          },
          onPanCancel: () {
            // 用户拖动取消时恢复 TabBarView 滑动
            setState(() {
            _isDragging = false;
            });
          },
          //悬浮窗
          child: const HomeChargeWindow(),
        ),
      ],
    ),
    //page2
    FollowPage(),
    //page3
    likeMePage(),  
  ],
)

```