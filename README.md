## QYXcodePlugIn
---
图图标呢

穷游版Xcode 开发插件，更好专注业务和思路，帮助ReviewCode 。

### 可以做什么？

 - 生成Getter&&Setter方法（包括categroy文件）
 - 请求文件生成校验方法和本地测试方法(*感谢张栋提供相关功能代码由CodeBulider*)
 - 格式化代码并输出
 - DIY文件模板
 - DIY代码片段
 - 录制热键
 - getter方法支持JSON格式自定义配置及其它功能配置
 - 重置Asset Catalog 文件搜索条件
 - 一些Automator workFlow服务
 - 异常提醒
 - 更多功能待扩展...
 
### 如何实现？

#### 1,Clang-Formate VS Uncrustify

Clang-Format

缺点：

- 缩进是硬伤
- 对于方法体中只有一行内容的方法,格式化后直接成了一行代码了。(clang-format + Re-Indent都不好使。也行是我配置有问题，但它真是个*Trouble*)

优点：

- 对block格式化支持比较好，无论嵌套的还是单一的。
- 比较成熟
 
Uncrustify

缺点：

-  对block 格式化简直无解,无论嵌套的和单一的

优点：

 - 缩进相较Clang-format 好些
 - 易于配置，跨平台
 
 [详细对比后](./cfVSUncrustify/clangFormatAnduncrustify.md)
   通过最终使用**Clang-format + Uncrustify**, 通过队列执行NSTask 任务来格式化拼接的代码。

#### 2,PromiseKit VS ReactiveCocoa
   Wow... 让我来隆重介绍 **[PromiseKit](http://promisekit.org/)**
   <div align='center'>
   ![](http://gitlab.dev/TangBin/QYXcodePlugIn/raw/master/promiseKit.png)
   </div>
  
  Promise模式在jQuery 1.5 版本中的应用，使其名声大噪。可以简单理解为延后执行,为异步任务的可能返回值指定相应的处理方法（承诺），使用block链式语法。
  
  PromiseKit 框架是[Max Howell](https://twitter.com/mxcl)传说中 Mac 下著名软件 Homebrew 的作者。支持object-c 和 swift。**配合 GCD、NSOperation、Block、链式语法、异常处理，执行异步、同步切换如写面向过程代码一样简单、清晰**。
  >[This means PromiseKit can essentially eat up any async spaghetti your codebase has been serving up](https://medium.com/the-traveled-ios-developers-guide/making-promises-417f13da901f#.iu9rmti1g) 
  
  **PromiseKit 可以轻易的吃掉你代码中的异步面条。。**😆😆😆
  
  🎉🎉🎉 *得益于PromiseKit 的强大功能和简洁语法，避免了该插件同、异步切换各种临时变量逻辑到处的错误处理变成一碗热干面的惨剧* 🍻🍻🍻
  


**VS   Reactive Cocoa**

  > *Reactive Cocoa is amazing, but requires a large shift in the way you program. PromiseKit is a happier compromise between the way most people program for iOS and a pure reactive paradigm. However, reactive programming is probably the future of our art.* - [PromiseKit Document](http://promisekit.org/appendix/)
 
PromiseKit 是轻量级的，而且是一次性的，意味着它不会照成循环引用，你不用到处写@weakify()/@strongify()，除少数情况下（那也不是PromiseKit 造成的引用循环）。

本插件出于性能考虑，同样是一次性的，意味着并不占用很多内存，除2个单例外，非常契合 PromiseKit。
> 杀鸡焉用牛刀
    
#### 3,ShortcutRecorder
[ShortcutRecorder](https://github.com/Kentzo/ShortcutRecorder)用于mac os x 10.6+ 下集成录制热键库。
核心：

 - ShortcutRecorder
 - PTHotKey
 
 
  <div align='center'>
   ![ShortcutRecorder](http://gitlab.dev/TangBin/QYXcodePlugIn/raw/master/ShortcutRecorder.png)
  </div>

 集成相当简单，可以参见文档。本想cocoapod 集成库却遇到了些麻烦，索性直接创建workspace文件，向插件引入第三方库。
 
 遇到了个有意思的问题：
 [如何正确地配置构建私有OS X框架](http://jaanus.com/how-to-correcty-configure-building-private-slash-embeddable-os-x-frameworks/)
 
#### 4,XcodeEditor
  参考：[XcodeEditor](https://github.com/appsquickly/XcodeEditor)
#### 5,LLDB && Dtrace && x86 assembly knowledge && Cycript
 - [lldb && Python-lldb](http://www.raywenderlich.com/?s=lldb) 工具
 - [Dtrace](https://www.objc.io/issues/19-debugging/dtrace/)
 - [x86 assembly knowledge](https://www.mikeash.com/pyblog/friday-qa-2011-12-16-disassembling-the-assembly-part-1.html) (汇编)
 - 很cool的 [Cycript](http://www.cycript.org/)支持javascript和oc 的混写
 
 用上面的技巧和工具可以让你做一些很cool的事。比如一些平时很无奈的私有API 在你面前几乎暴露无疑。。
 
 *如果你有兴趣听我分享一些思路和经验，不防移步这里看看。
 
 > [调教Xcode: 重置Asset Catalog资源列表搜索条件](./clearCalagoy/modifiedXcode.md)

#### 6,Automator workFlow

Automator可以做一些Services，来执行一些shell 脚本。
 
 - [Sort_Import](./workflow/SortImport.workflow)
 - [Uncrustify Objective-C](./workflow/UncrustifyObjective-C.workflow)
 
 点击安装 Automator&Services 🍻🍻
 

### 怎么用？

#### 1,安装

	 git clone git@gitlab.dev:TangBin/QYXcodePlugIn.git
	 cd QYXcodePlugIn/
	 //一键安装插件🍻🍻
	 ./setupHelper.sh
	 
#### 2,配置热键和其它选项
     
	 Edit->QYAction->Preferences

 - AutoGeter 执行热键或点击对应菜单
 - RequestValidetor 在对应请求文件中执行热键或点击对应菜单
 - Preferences 自定义配置getter 或 重置Calagoy 搜索条件
 
#### 3,DIY文件模板
  请移步:
  [如何DIY Xcode文件模板](./fileTemplte/creatFileTemplte.md)
   
#### 4,DIY代码片段

 > *这个还是自己玩吧, 如果共享一旦在本地片段key重复，Xcode将无法启动*
  
  **~/Library/Developer/Xcode/UserData/CodeSnippets已经镜像到了QYXcodePlugin/ CodeSnippets 文件导航目录，如果你在导航看不到，可以在show in finder 进行管理。**
  
#### 5，小提示
> 如要调试插件，QYXcodePlugIn 切到debug模式,如果编译失败找不到ShortcutRecorder/PTHotKey 相关文件，请切到这两个Scheme 分别编译一次。  

### 未来
#### 1,ReviewCode

     ReviewCode老生常谈的一个话题，真正实现也需要一些精力、时间及制度，使之常态化。
   
     QYXcodePlign 提供的文件模板可以通过Git Brance 共享和个性化定制，也许你可以思考和总结你的代码风格并整理成模板，是否可以帮助ReviewCode呢？
   
     当然，使用QYXcodePlign 文件模板不意味着永远固化的代码风格，你可以随时改变如果你认为或大家都认同那是更好的。
#### 2,待完善
  
  - cocoapod 支持
  - Preferences UI 使用类Xcode  Preferences 控件支持😏😏😏
  - 其它待扩展
  
  > 如果你在工作中有什么可以提高效率或者一个很cool的想法，不防用插件实现分享给大家。
  
  
###  🍻🍻🍻🍻🍻  Enjoy. If it helps you  🎉🎉🎉🎉🎉