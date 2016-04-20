//
//  QYMenuBaseItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/21.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYMenuBaseItem.h"

@implementation QYMenuBaseItem

-(void)dealloc{
    if (self.target) {
        self.target = nil;
    }
}

-(void)bindDynamicHoteKey{
    //TODO
    
}

-(void)menuItemAction:(id)sender{
    //TODO
    [[[QYXcodePlugIn sharedPlugin] notificationHandler] clangFormateContentPath];
    
}

@end
