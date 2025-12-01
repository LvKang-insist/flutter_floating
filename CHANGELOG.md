### v2.0.0
重大更新，重构代码结构，优化使用体验，增加更多功能

[部分 API 不兼容，请参考文档进行修改](https://github.com/kngLv/flutter_floating/blob/master/README.md)

### v1.1.2
增加页面内悬浮窗的支持，[参考](https://github.com/LvKang-insist/flutter_floating/tree/master/lib/page/internal_floating_page.dart)

### v1.1.1
![修复当设置为吸附左边时，悬浮窗位置不正确的问题](https://github.com/LvKang-insist/flutter_floating/issues/37 )
去掉屏幕宽高改变的日志
增加滑动结束后吸附边缘时的速度 edgeSpeed

### v1.1.0
修复悬浮窗外尺寸发生变化时悬浮窗位置未恢复的问题

### v1.0.8
增加获取位置的api
创建 Floating 时可根据自定义的屏幕位置(Point)创建
修改回调事件中的参数为 Point
修改部分api，优化代码

### v1.0.7
增加吸附边缘的时候的自定义吸附边缘边距，优化代码逻辑

### v1.0.6
增加悬浮窗控制状态，优化代码逻辑

### v1.0.5
增加自动回弹位置的控制，可自由选择靠左，靠右或者是自动识别

### v1.0.4
增加悬浮窗移动 Api，修改bug，提高使用体验

### v1.0.3
修改部分bug，优化代码

### v1.0.2
修改部分Api，新增对悬浮窗大小改变时悬浮窗位置的适配，优化代码

### v1.0.1
项目迁移至 flutter3.0，3.0一下可能无法使用，请自行升级flutters SDK

### v0.1.6
修复 moveEndListener 无法回调，优化内部逻辑。flutter 3.0以下使用

### v0.1.5
修复一些已知的问题，提高使用体验

### v0.1.4
由于 v0.1.3 版本导致 flutter3.0 以下无法使用，所以，flutter3.0 以下 请使用 v0.1.4，3.0及以上使用 v0.1.3即可

### v0.1.3
适配 flutter 3.O，修改一些已知问题

### v0.1.2
修改部分API,优化使用体验

### v0.1.1
修复位置缓存无作用的问题 ,新增边缘吸附的控制 ,优化使用体验...

### v0.1.0
修复点击事件的bug ,优化开发体验，自适应子组件的大小，无需手动传入大小 ,其他bug

### v0.0.1
一个灵活和强大的悬浮窗口解决方案