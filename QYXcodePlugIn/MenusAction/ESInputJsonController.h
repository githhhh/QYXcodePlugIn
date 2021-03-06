//
//  TestWindowController.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/19.
//  Modefied by 唐斌
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QYWindowsCloseProtocol.h"

@interface ESInputJsonController : NSWindowController

@property (nonatomic,assign) BOOL isJsonModel;

@property (nonatomic,strong) NSTextView *editorView;

@property (nonatomic,copy) NSString *currentImpleMentationPath;

@property (nonatomic,weak) id<QYWindowsCloseProtocol> delegate;

@end
