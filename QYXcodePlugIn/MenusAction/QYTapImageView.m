//
//  QYTapImageView.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/3/23.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "QYTapImageView.h"

@implementation QYTapImageView


- (void)mouseDown:(NSEvent *)theEvent {
    
    [NSApp sendAction:[self action] to:[self target] from:self];
    
}


@end
