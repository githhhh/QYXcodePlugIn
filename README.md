# QYXcodePlugIn

![logo](http://gitlab.dev/TangBin/QYXcodePlugIn/raw/master/logo.png)

穷游iOS开发团队专属 Xcode plugin ,旨在更好专注业务逻辑 , 统一代码风格 ,帮助Code Review。

## 能干点啥
* Auto Getter-Setter   (*包括Category文件*)

* 生成 Request file 校验方法和本地测试数据方法  (*使用[YTKNetwork](https://github.com/yuantiku/YTKNetwork)封装单个请求*)

* [DIY 文件模板](./fileTemplte/creatFileTemplte.md)  (*直接在Xcode 中修改，无需重启*)

* [重置 Asset Catalog 资源列表搜索条件](./clearCalagoy/modifiedXcode.md) (*A cool feature*)

* 该插件配置功能  (*JSON 格式配置Getter内容、绑定菜单热键、异常提醒、其它配置*)

* 一些Automator workFlow服务 (*项目目录workflow 下，点击安装*)

* 封装API: 格式化代码并输出   (*[使用Clang-Formate + Uncrustify中和各自优缺点](./cfVSUncrustify/clangFormatAnduncrustify.md)*)

* 更多功能待扩展...


## 安装

    > git clone git@gitlab.dev:TangBin/QYXcodePlugIn.git
	> cd QYXcodePlugIn/
	> ./setupHelper.sh
	
🍻🍻

## 演示
![auto-getter](http://gitlab.dev/TangBin/QYXcodePlugIn/raw/master/auto-getter.gif)
## 如何扩展功能

-ShortcutRecorder(project)
 
-QYXcodePlugIn (project)
 
 * CodeSnippets    镜像的xcode 自定义代码片段(show in finder)
 * QYFileTemplate  管理DIY 的文件模板，可以直接修改模板内容。
 * QYXcodePlugIn   插件功能目录
 
   * Magic 彩蛋。。
   * Model 插件的配置信息Model
   * Menus 封装了NSMenuItem和绑定热键操作
   * MenusAction 菜单响应文件
   * Resources xib 文件
   * Main 启动单例类
   * Uitility 一些帮助文件或库
 
 
 插件大量使用 [PromiseKit](./promiseKit.md)封装API、整理同异步代码。
 
 > 使用cocoapod 管理PromiseKit,关于集成中的问题见：
 - [直接集成报错 ld: library not found for -lxxx ？？](http://stackoverflow.com/questions/32540495/xcode-plugin-template-cocoapods)
 - [用上面方法后,启动xcode实例调试，崩了？？？](https://github.com/XVimProject/XVim/issues/628)
 
 使用[ShortcutRecorder](https://github.com/Kentzo/ShortcutRecorder)轻松实现绑定热键到菜单或按钮。
 
 > 该插件使用workspace文件管理QYXcodePlugIn 和 ShortcutRecorder,不支持cocoapod。
 - [如何正确地配置构建私有OS X框架](http://jaanus.com/how-to-correcty-configure-building-private-slash-embeddable-os-x-frameworks/)

 其它技能：
 
 - [lldb && Python-lldb](http://www.raywenderlich.com/?s=lldb) 工具
 - [Dtrace](https://www.objc.io/issues/19-debugging/dtrace/)
 - [x86 assembly knowledge](https://www.mikeash.com/pyblog/friday-qa-2011-12-16-disassembling-the-assembly-part-1.html) (汇编)
 - [Cycript](http://www.cycript.org/)支持javascript和oc 的混写
 
 
 关于插件调试：
 > 需要把所有Scheme 都切换到Debug模式,Demo除外,每个重新编译一下。 
 
###  🍻🍻🍻🍻🍻  Enjoy. If it helps you  🎉🎉🎉🎉🎉