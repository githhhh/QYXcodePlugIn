# 功能
*  共享常用文件模板和代码片段
*  支持格式代码并输出 
*  其它待扩展(共同维护，尽量少点体力劳动)



# 性能

    所有操作均异步执行，执行完成后并不占用很多内存，除 一个监听XCode 的单例对象。


# 依赖
    
     clang-format 

# 安装依赖、镜像模板
     
     git clone git@gitlab.dev:TangBin/QYXcodePlugIn.git
     cd QYXcodePlugIn
     ./setup_CodeHelper.sh


#  加载/更新 插件

     open QYXcodePlugIn.xcodeproj
     command + R
 
#  QYXcodePlugIn使用
 Edit->QYAction->AutoGetter     热键：control + F
 
      触发条件：在.m 文件中选择私有属性 
          
      自动生成Getter方法，只支持"引用类型" 如：
        
      @property (copy, nonatomic) NSString *testName;
        
      "值类型"将被忽略 如： NSInterge
        
        
 Edit->QYAction->请求类校验方法  热键：control + S
 
 
       触发条件：只有当前打开文件是QYRequest 的子类，并且在.m 文件中。否则没有反应
        
       生成对应请求类的 校验方法和测试数据方法。
       
 
 
 Edit->QYAction->Seting   
 
       支持
           自定义getter方法，数据格式为JSON 可以在线编辑完后覆盖保存。
           
       待支持 
           自定义热键