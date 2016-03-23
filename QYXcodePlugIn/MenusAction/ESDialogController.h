//
//  ESDialogController.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/26.
//  Modefied by 唐斌
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void(^CallBackBlock)(NSString *name);

@interface ESDialogController : NSWindowController

@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *prefixName;


- (void)setDataWithMsg:(NSString *)msg
      defaultClassName:(NSString *)className
        classNameBlock:(CallBackBlock)confirmClassNameBlock
           prefixBlock:(CallBackBlock)confirmPrefixBlock
            breakBlock:(void(^)(void))breakBlock;


@end
