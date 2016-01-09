//
//  QYSettingModel.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/22.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYSettingModel : NSObject<NSCoding>

@property (nonatomic,copy  ) NSString *getterJSON;
@property (nonatomic,copy  ) NSString *requestClassBaseName;
@property (nonatomic,assign) BOOL     isCreatTestMethod;
@property (nonatomic,copy  ) NSString *testMethodName;
@property (nonatomic,copy  ) NSString *requestValidatorMethodName;

@property (nonatomic,assign) BOOL     isClearCalalogSearchTitle;


@end
