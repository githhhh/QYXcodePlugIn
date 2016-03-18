//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//  Template From QYXcodePlugin
//

#import "___FILEBASENAME___.h"
#import "Masonry.h"

@implementation ___FILEBASENAMEASIDENTIFIER___

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}


#pragma mark - bindViewModel && handleEvent




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



@end
