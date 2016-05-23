//
//  QYUpdateModel.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/4/11.
//  Copyright © 2016年 X.Y. All rights reserved.
//  Template From QYXcodePlugin
//

#import "QYUpdateModel.h"
#import "MHXcodeDocumentNavigator.h"
#import "Promise.h"
#import "QYClangFormat.h"
#import "QYUpdateAlert.h"
#import "QYXcodePlugIn.h"

#define checkVersionCommand(gitPath,infoPath) [NSString stringWithFormat:@"cd \'%@\'\ngit pull origin master \nversion=`/usr/libexec/PlistBuddy -c \"Print :CFBundleShortVersionString\" \"%@\"`\necho \"versionStr=$version\"",gitPath,infoPath]

#define updateCommand(gitPath) [NSString stringWithFormat:@"\ncd \'%@\'\n\n./setupHelper.sh up\n",gitPath]

@interface QYUpdateModel ()

@property (nonatomic, retain) QYUpdateAlert *alert;

/**
 *  项目目录 和plist 目录
 */
@property (nonatomic, retain) NSArray *pathArr;

@end

@implementation QYUpdateModel

-(void)dealloc{
    
    LOG(@"==QYUpdateModel====dealloc==");
}

-(void)updateVersion{

    dispatch_promise_on(dispatch_get_global_queue(0, 0), ^id{
    
        NSBundle *bundle = [NSBundle bundleWithIdentifier:@"X.Y.QYXcodePlugIn"];
        NSString *version = [[bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *paths = [[bundle infoDictionary] objectForKey:@"QYXcodePlugInGitPath"];
        
        self.pathArr = [paths componentsSeparatedByString:@"@@"];
        
        //异步获取最新代码
        NSString *outStr = [QYClangFormat runCommand:checkVersionCommand(self.pathArr[0],self.pathArr[1])];
        
        if (IsEmpty(outStr)) {
            return error(@"更新未知错误。。。。。", 0, nil);
        }
        NSString *lastVersion = nil;
        outStr = [outStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ( [outStr hasPrefix:@"versionStr="] ) {
            return error(@"ssh: connect to host gitlab.dev port xx: Network is unreachable\nfatal: Could not read from remote repository.\n\nPlease make sure you have the correct access rights\nand the repository exists.", 0, nil);
        }else{
            NSRange lastVersionStrRange = [outStr rangeOfString:@"versionStr="];
            lastVersion = [outStr substringFromIndex:(lastVersionStrRange.location+lastVersionStrRange.length)];
        }
        
        lastVersion = [lastVersion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        version = [version stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        
        return PMKManifold(version,lastVersion,outStr);

    }).thenOn(dispatch_get_main_queue(),^(NSString *version,NSString *lastVersion,NSString *outStr){

        if ([lastVersion floatValue] > [version floatValue]) {
            
            self.alert.title = @"QYXcodePlugIn插件有新的可用更新~！";
            self.alert.cancelTitle = @"瘪来烦我！";
            self.alert.confirmTitle = @"立即更新!";
            self.alert.msg = outStr;
            
            weakify(self);
            self.alert.confirmBlock = ^(NSInteger idex){
                strongify(self);

                if (idex == 0) {
                    //更新 alert
                    strongSelf.alert.alertTitle.stringValue = @"正在更新...";
                    strongSelf.alert.alertMessage.string = @"等待执行结果...";
                    strongSelf.alert.cancelBtn.hidden = true;
                    [strongSelf.alert.confirmBtn setTitle:@"更新中..."];
                    strongSelf.alert.confirmBtn.enabled = false;
                    
                    [strongSelf updateNow];
                    
                    return ;
                }else if (idex == 1){
                    //不更新
                    NSUserDefaults *userDf = [NSUserDefaults standardUserDefaults];
                    
                    [userDf setValue:@"1" forKey:IsCheckUpdate];
                    
                    [userDf synchronize];
                    /**
                     *  释放window
                     */
                    if (strongSelf.alert) {
                        [strongSelf.alert.window close];
                        strongSelf.alert.window = nil;
                        strongSelf.alert = nil;
                    }
                    if (strongSelf.confirmBlock) {
                        strongSelf.confirmBlock();
                    }

                }
               
            };
            
            [self.alert showWindow:self];
            
        }

    }).catchOn(dispatch_get_main_queue(),^(NSError *err){

        self.alert.title = @"QYXcodePlugIn插件更新出错啦！！";
        
        self.alert.cancelTitle = @"";
        self.alert.confirmTitle = @"ok!";
        self.alert.msg = dominWithError(err);
        
        
        weakify(self);
        self.alert.confirmBlock = ^(NSInteger idex){
            strongify(self);
            
            /**
             *  释放window
             */
            if (strongSelf.alert) {
                [strongSelf.alert.window close];
                strongSelf.alert.window = nil;
                strongSelf.alert = nil;
            }
            if (strongSelf.confirmBlock) {
                strongSelf.confirmBlock();
            }
            
        };

        [self.alert showWindow:self];
        self.alert.cancelBtn.hidden = true;
    });
    
}

#pragma mark - Private Methode

-(void)updateNow{
    
    //执行bulid 最新代码。异步加载pluginDidLoad：
    dispatch_promise_on(dispatch_get_global_queue(0, 0), ^id{
        if (!self.pathArr) {
            return nil;
        }
        NSString *outStr = [QYClangFormat runCommand:updateCommand(self.pathArr[0])];

        return outStr;
    
    }).thenOn(dispatch_get_main_queue(),^(NSString *outStr){
        if (!outStr) {
            return ;
        }
        self.alert.confirmBtn.enabled = true;
        self.alert.alertMessage.string = @"** BUILD SUCCEEDED **\n 🎉  😉  Enjoy.Go!  🚀   🍻";
        self.alert.alertTitle.stringValue = @"执行成功！";
        [self.alert.confirmBtn setTitle:@"ok"];

        weakify(self);
        self.alert.confirmBlock = ^(NSInteger idex){
            strongify(self);
            /**
             *  释放window
             */
            if (strongSelf.alert) {
                [strongSelf.alert.window close];
                strongSelf.alert.window = nil;
                strongSelf.alert = nil;
            }
            if (strongSelf.confirmBlock) {
                strongSelf.confirmBlock();
            }
            
            /**
             *  重新加载QYXcodePlugIn
             */
            [[[QYXcodePlugIn sharedPlugin] notificationHandler] didApplicationFinishLaunchingNotification:nil];
        };
        
    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
        
        self.alert.confirmBtn.enabled = true;
        self.alert.alertMessage.string = @"更新失败啦...";
        self.alert.alertTitle.stringValue = @"更新失败啦...";
        [self.alert.confirmBtn setTitle:@"稍后再试吧！"];

        weakify(self);
        self.alert.confirmBlock = ^(NSInteger idex){
            strongify(self);
            /**
             *  释放window
             */
            if (strongSelf.alert) {
                [strongSelf.alert.window close];
                strongSelf.alert.window = nil;
                strongSelf.alert = nil;
            }
            if (strongSelf.confirmBlock) {
                strongSelf.confirmBlock();
            }
        };

    });
    
}


#pragma mark -  AutoGetter

- (QYUpdateAlert *)alert {
    if (!_alert) {
        _alert = [[QYUpdateAlert alloc] initWithWindowNibName:@"QYUpdateAlert"];
    }

    return _alert;
}

@end
