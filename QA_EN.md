# FAQ

1. When using a floating widget inside a TabBarView page, dragging the floating widget horizontally may conflict with the TabBarView's page swiping. How to resolve?

Solution:

Wrap your page with a gesture detector that disables the TabBarView's scroll while the floating is being dragged. Example:

```dart
bool _isDragging = false;

TabBarView(
  controller: _tabController,
  // Key part: disable scrolling while dragging
  physics: _isDragging ? const NeverScrollableScrollPhysics() : null,
  children: [
    // page1
    Stack(
      children: [
        const AkDDHomeTabHot(),
        GestureDetector(
          onPanDown: (details) {
            // Disable TabBarView scrolling when user starts pressing
            setState(() {
              _isDragging = true;
            });
          },
          onPanUpdate: (details) {
            // Keep disabled while dragging
            setState(() {
              _isDragging = true;
            });
          },
          onPanEnd: (details) {
            // Re-enable TabBarView scrolling when drag ends
            setState(() {
              _isDragging = false;
            });
          },
          onPanCancel: () {
            // Re-enable TabBarView scrolling when drag is cancelled
            setState(() {
              _isDragging = false;
            });
          },
          // Floating widget
          child: const HomeChargeWindow(),
        ),
      ],
    ),
    // page2
    FollowPage(),
    // page3
    likeMePage(),  
  ],
)
```

