//
//  QYInputJsonController.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/24.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QYWindowsCloseProtocol.h"
#import "Promise.h"

@interface QYRequestVerifyController : NSWindowController

@property (nonatomic,strong) NSTextView *sourceTextView;

@property (nonatomic,retain) NSValue *insertRangeValue;

@property (nonatomic,weak) id<QYWindowsCloseProtocol> delegate;
@end
