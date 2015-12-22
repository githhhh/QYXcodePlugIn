//
//  CategoryGetterSetterAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/16.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "CategoryGetterSetterAchieve.h"
#import "Promise.h"

@implementation CategoryGetterSetterAchieve


-(void)createCategoryGetterSetterAction{
    NSString *selecteText  = globleParamter;
    
    PMKPromise *pmk = [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        fulfill(@1);
    }];
    
    pmk.then(^(NSNumber *number){
    
        NSLog(@"====%@==",number);
    
    });
    
};









@end
