# Clang-formate VS Uncrustify
---
## Clang-formate

  [Clang-formate](http://clang.llvm.org/docs/ClangFormat.html): clang-llvm 编译器自带格式代码工具,使用前需要安装clang-format。
   
>	  brew install clang-format

   使用[.clang-formate](https://github.com/Lede-Inc/LDSDKManager_IOS/blob/master/.clang-format) 放在根目录来自定义全局配置，或者放在单独的项目根目录处理源代码，支持除llvm 外多种风格。
   
   或者直接在脚本中指定配置
    
>	   clang-format -style="{BasedOnStyle: llvm,AlignTrailingComments: true....}" [-line<startLoc:endLoc>] filepath
		
   想了解更多clang-format配置这里有个[演示](http://clangformat.com/)不错
   
   当然还有出名的 [ClangFormat-Xcode](https://github.com/travisjeffery/ClangFormat-Xcode),可见它相当成熟。
   
   但它在**多层嵌套的字典、数组、block代码中缩进效果却差强人意**。（至少我折腾半天也没fix）,所以要配合XCode 自带的自动感知缩进Re-indent (contr + i)
   <div align='center'>
     ![Re-indent](http://git.2b6.me/iOS/QYXcodePlugIn/raw/master/cfVSUncrustify/reindent.png)
   </div>
   
## Uncrustify
   
   幸运的是找到了[Uncrustify](https://github.com/bengardner/uncrustify),支持多种语言并且跨平台，非常容易配置。及相关插件[BBUncrustifyPlugin-Xcode](https://github.com/benoitsan/BBUncrustifyPlugin-Xcode),使用[.uncrustify.cfg](https://gist.github.com/ryanmaxwell/4242629)放在根目录下作为配置文件。
   
   它的缩进效果相对clang-format要好些,but 它对block 的格式化[简直无解](http://stackoverflow.com/questions/16464285/uncrustify-nested-block-indeting-is-wrong)..。
   
   作者也在修复中。
   
   >[The current distributed version of uncrustify has some shortcomings when it comes to formatting objective-c code properly, specifically messages and blocks. I have been working on fixes. :)](https://github.com/markeissler/wonderful-objective-c-style-guide)



## 貌似没有很完美的格式化代码工具

>孟子曰: 鱼,我所欲也;熊掌,亦我所欲也;二者不可得兼。but，混在一起炖汤，大补耶。

炒着吃应该也不懒😉

![](http://git.2b6.me/iOS/QYXcodePlugIn/raw/master/cfVSUncrustify/pop.gif)

	
>	/usr/local/bin/clang-format -style="{BasedOnStyle: llvm,AlignTrailingComments: true,BreakBeforeBraces: Linux,ColumnLimit: 120,IndentWidth: 4,KeepEmptyLinesAtTheStartOfBlocks: false,MaxEmptyLinesToKeep: 2,ObjCSpaceAfterProperty: true,ObjCSpaceBeforeProtocolList: true,PointerBindsToType: false,SpacesBeforeTrailingComments: 1,TabWidth: 4,UseTab: Never,BinPackParameters: false}"  /Users/qyer/Desktop/temp.m | /usr/local/bin/uncrustify  -q -c ~/.uncrustify.cfg -l OC



*来看看是否美味？*

*原代码* 😖😖😖

	- (id)validatorResult {
	    return @{@"cn_name" : [NSString class], @"city_id" : [NSNumber class], @"pic_url" : [NSString class], @"wifi_url" : [NSString class], @"traffic_url" : [NSString class], @"place_id" : [NSString class], @"ticket_url" : [NSString class], @"visa_url" : [NSString class], @"en_name" : [NSString class] };
	}
	
	- (NSDictionary *)testData {
	    return@{@"status" : @(1), @"msg" : @"", @"data" : @{@"cn_name" : @"东京", @"city_id" : @(12), @"pic_url" : @"http://xx.com/pic...", @"wifi_url" : @"http://xx.com/....", @"traffic_url" : @"http://xx.com/....", @"place_id" : @"JmwMFx+4+5o=", @"ticket_url" : @"http://xx.com/..", @"visa_url" : @"http://xx.com/....", @"en_name" : @"Tokyo" } };
	}

😉😉😉🎉🎉🎉🍻🍻🍻 **一起炖？？？？** 😉😉😉🎉🎉🎉🍻🍻🍻
	
	- (id)validatorResult {
	    return @{
	               @"lon": [NSString class],
	               @"map": [NSString class],
	               @"folder_id": [NSString class],
	               @"sub_title": [NSString class],
	               @"introduction": [NSString class],
	               @"folder_name": [NSString class],
	               @"is_book": [NSNumber class],
	               @"title": [NSString class],
	               @"comment_num": [NSNumber class],
	               @"price": [NSString class],
	               @"product_id": [NSString class],
	               @"lat": [NSString class],
	               @"comment_level": [NSString class],
	               @"address": [NSString class],
	               @"booking_before": [NSString class],
	               @"highlights": @[ [NSString class] ],
	               @"photos": @[ [NSString class] ],
	               @"purchase_info": [NSString class]
	    };
	}
	
	\#warning 本地测试数据，正式环境需要注释或删除
	
	- (id)testData {
	    return @{
	               @"status": @(1),
	               @"msg": @"",
	               @"data": @{
	                   @"lon": @"113.9",
	                   @"map": @"http://7xoe6n.com2.z0.glb.qiniucdn.com/map-16576-16191.png",
	                   @"folder_id": @"sd#vsadd=",
	                   @"sub_title": @"米尔福德峡湾一日游",
	                   @"introduction": @"米尔福德峡湾位于新西兰的地方....",
	                   @"folder_name": @"addd",
	                   @"is_book": @(1),
	                   @"title": @"米尔福德峡湾一日游",
	                   @"comment_num": @(17),
	                   @"price": @"100-300",
	                   @"product_id": @"SShfvLm9hmw=",
	                   @"lat": @"22.5",
	                   @"comment_level": @"4.5",
	                   @"address": @"清华东路西口",
	                   @"booking_before": @"3",
	                   @"highlights": @[ @"亮点1", @"亮点2" ],
	                   @"photos": @[ @"http://xx.com/photos....", @"http://xx.com/photos...." ],
	                   @"purchase_info": @"http://topic.joy.com/pay_notes/27.html"
	               }
	    };
	}


clang-format + Re-Indent(**ctrol+i**)	(勉强吧。。。😐😐😐,但这里讨论的是使用纯shell在程序中执行。)

	- (id)validatorResult
	{
	    return @{
	             @"lon" : [NSString class],
	             @"map" : [NSString class],
	             @"folder_id" : [NSString class],
	             @"sub_title" : [NSString class],
	             @"introduction" : [NSString class],
	             @"folder_name" : [NSString class],
	             @"is_book" : [NSNumber class],
	             @"title" : [NSString class],
	             @"comment_num" : [NSNumber class],
	             @"price" : [NSString class],
	             @"product_id" : [NSString class],
	             @"lat" : [NSString class],
	             @"comment_level" : [NSString class],
	             @"address" : [NSString class],
	             @"booking_before" : [NSString class],
	             @"highlights" : @[ [NSString class] ],
	             @"photos" : @[ [NSString class] ],
	             @"purchase_info" : [NSString class]
	             };
	}
	
	- (NSDictionary *)testData
	{
	    return @{
	             @"status" : @(1),
	             @"msg" : @"",
	             @"data" : @{
	                     @"lon" : @"113.9",
	                     @"map" : @"http://7xoe6n.com2.z0.glb.qiniucdn.com/map-16576-16191.png",
	                     @"folder_id" : @"sd#vsadd=",
	                     @"sub_title" : @"米尔福德峡湾一日游",
	                     @"introduction" : @"米尔福德峡湾位于新西兰的地方....",
	                     @"folder_name" : @"addd",
	                     @"is_book" : @(1),
	                     @"title" : @"米尔福德峡湾一日游",
	                     @"comment_num" : @(17),
	                     @"price" : @"100-300",
	                     @"product_id" : @"SShfvLm9hmw=",
	                     @"lat" : @"22.5",
	                     @"comment_level" : @"4.5",
	                     @"address" : @"清华东路西口",
	                     @"booking_before" : @"3",
	                     @"highlights" : @[ @"亮点1", @"亮点2" ],
	                     @"photos" : @[ @"http://xx.com/photos....", @"http://xx.com/photos...." ],
	                     @"purchase_info" : @"http://topic.joy.com/pay_notes/27.html"
	                     }
	             };
	}

*单独使用clang-format (差点意思,缩进为4)* 😅😅😅

	- (id)validatorResult
	{
	    return @{
	        @"cn_name" : [NSString class],
	        @"city_id" : [NSNumber class],
	        @"pic_url" : [NSString class],
	        @"wifi_url" : [NSString class],
	        @"traffic_url" : [NSString class],
	        @"place_id" : [NSString class],
	        @"ticket_url" : [NSString class],
	        @"visa_url" : [NSString class],
	        @"en_name" : [NSString class]
	    };
	}
	
	- (NSDictionary *)testData
	{
	    return @{
	        @"status" : @(1),
	        @"msg" : @"",
	        @"data" : @{
	            @"cn_name" : @"东京",
	            @"city_id" : @(12),
	            @"pic_url" : @"http://xx.com/pic...",
	            @"wifi_url" : @"http://xx.com/....",
	            @"traffic_url" : @"http://xx.com/....",
	            @"place_id" : @"JmwMFx+4+5o=",
	            @"ticket_url" : @"http://xx.com/..",
	            @"visa_url" : @"http://xx.com/....",
	            @"en_name" : @"Tokyo"
	        }
	    };
	}

*单独使用 Uncrustify (没啥变化)* 😓


**以上仅供参考**


>如果你发现可以通过配置来解决上面问题，何不fix??