//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//  Template From QYXcodePlugin
// 

#import "___FILEBASENAME___.h"

@implementation ___FILEBASENAMEASIDENTIFIER___
/*
- (id)init {
    return [self initWithFrame:CGRectZero]; // or default Rect
}
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - bindViewModel

#pragma mark - handleEvent


#pragma mark - updateConstraints

/**
 *  tell UIKit that you are using AutoLayout
 */
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

/**
 *  this is Apple's recommended place for adding/updating constraints
 */
-(void)updateConstraints {
    //TODO AutoLayout update/add
    
    
    [super updateConstraints];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Getter




@end
