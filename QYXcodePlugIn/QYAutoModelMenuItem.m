//
//  QYAutoModelMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/3/14.
//  Copyright © 2016年 X.Y. All rights reserved.
//  Template From QYXcodePlugin
//

#import "QYAutoModelMenuItem.h"
#import "Promise.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Files.h"
#import "NSString+Extensions.h"
#import "QYXcodePlugIn.h"

@implementation QYAutoModelMenuItem
-(instancetype)init{
    self = [super init];
    if (self) {
        self.target = self;
        self.action = @selector(menuItemAction:);
        self.title = QYMenu_AutoModel;
    }
    return self;
}

-(void)menuItemAction:(id)sender{
    [super menuItemAction:sender];
    
    //action
    self.windowDelegate = [[QYXcodePlugIn sharedPlugin] notificationHandler];
    
    PMKPromise *promise = dispatch_promise_on(dispatch_get_main_queue(), ^id(){
    
        NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];
        BOOL isHeaderFile = [currentFilePath isHeaderFilePath];
    
        if (!isHeaderFile)
            return error(@"要在头文件调用该功能哦！！", 0, nil);
        
        //读取配置
        NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
        NSString *rootClassName = [currentFilePath currentClassName];
        // 验证当前.h 文件的父类是否是制定类
        NSError *matchError;
        NSArray *contents =
        [textView.string matcheGroupWith:[NSString stringWithFormat:@"@\\w+\\s*(%@)\\s*\\:\\s+(\\w+)\\s",rootClassName] error:&matchError];
       
        if (matchError||!contents||[contents count] == 0)
            return error(@"为什么没有匹配到头文件声明呢。。~\(≧▽≦)/~", 0, nil);
        if ([contents[2] isEqualToString:@"JSONModel"]) {
            return @(1);
        }else if ([contents[2] isEqualToString:@"NSObject"]){
            return @(0);
        }else{
            return error(@"AutoModel 暂只识别NSObject、JSONModel哦！", 0, nil);
        }
    });
    
    if (self.windowDelegate && [self.windowDelegate respondsToSelector:@selector(receiveMenuItemPromise:sender:)]) [self.windowDelegate receiveMenuItemPromise:promise sender:self];
}



#pragma mark - 动态绑定热键
-(void)bindDynamicHoteKey{
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [self bind:@"keyEquivalent"
      toObject:defaults
   withKeyPath:AutoModelMenuKeyPath
       options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    
    [self bind:@"keyEquivalentModifierMask"
      toObject:defaults
   withKeyPath:AutoModelMenuKeyPath
       options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
    
}

@end
