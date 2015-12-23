//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Template From QYXcodePlugin
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"

@interface ___FILEBASENAMEASIDENTIFIER___()

@end

@implementation ___FILEBASENAMEASIDENTIFIER___

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
        
    }
    return self;
}

-(void)configWithData:(id)data{
    if (!data||![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
}

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
-(void)updateConstraints{
    //TODO AutoLayout update/add
    
    
    [super updateConstraints];
}




@end
