//
//  QYInputJsonController.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/24.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QYWindowsCloseProtocol.h"
@interface QYInputJsonController : NSWindowController

@property (nonatomic,strong) NSTextView *sourceTextView;
@property (nonatomic,weak) id<QYWindowsCloseProtocol> delegate;
@end
