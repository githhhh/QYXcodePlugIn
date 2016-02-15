
# PromiseKit VS ReactiveCocoa
---

## [PromiseKit](http://promisekit.org/)

  
   <div align='center'>
   ![](http://gitlab.dev/TangBin/QYXcodePlugIn/raw/master/promiseKit.png)
   </div>
  
  Promise模式在jQuery 1.5 版本中的应用，使其名声大噪。可以简单理解为延后执行,为异步任务的可能返回值指定相应的处理方法（承诺），使用链式语法。
  
  PromiseKit 框架是[Max Howell](https://twitter.com/mxcl)传说中 Mac 下著名软件 Homebrew 的作者。支持object-c 和 swift。**配合 GCD、NSOperation、Block、链式语法、异常处理，执行异步、同步切换如写面向过程代码一样简单、清晰**。
  >[This means PromiseKit can essentially eat up any async spaghetti your codebase has been serving up](https://medium.com/the-traveled-ios-developers-guide/making-promises-417f13da901f#.iu9rmti1g) 
  
  **PromiseKit 可以轻易的吃掉你代码中的异步面条。。**😆😆😆
  
  🎉🎉🎉 *得益于PromiseKit 的强大功能和简洁语法，避免了该插件同、异步切换各种临时变量逻辑到处的错误处理变成一碗热干面的惨剧* 🍻🍻🍻
  


##VS   Reactive Cocoa

  > *Reactive Cocoa is amazing, but requires a large shift in the way you program. PromiseKit is a happier compromise between the way most people program for iOS and a pure reactive paradigm. However, reactive programming is probably the future of our art.* - [PromiseKit Document](http://promisekit.org/appendix)
 
PromiseKit 是轻量级的，而且是一次性的，意味着它不会照成循环引用，你不用到处写@weakify()/@strongify()，除少数情况下（那也不是PromiseKit 造成的引用循环）。

本插件出于性能考虑，同样是一次性的，意味着并不占用很多内存，除2个单例外，非常契合 PromiseKit。


##注意PromiseKit的错误处理：
    
 
> 尽量使用return error的方式 在promise block块中返回错误，虽说使用@throw error 很方便。**后者会造成"循环引用" 造成对象不释放。**
 
 


 




  
  
