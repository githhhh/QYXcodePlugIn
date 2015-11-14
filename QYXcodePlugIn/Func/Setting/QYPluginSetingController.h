//
//  QYPluginSetingController.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/6.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QYWindowsCloseProtocol.h"
#define  geterSetingKey @"allGeter"
#define  rqBName @"rqBName"
#define  isTD @"isTestDate"
#define  testdateMethodName @"tdMethodName"
#define  validatorMName @"validatorMName"

@interface QYPluginSetingController : NSWindowController
@property (nonatomic,weak) id<QYWindowsCloseProtocol> pgDelegate;
@end
