//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"

@interface ___FILEBASENAMEASIDENTIFIER___()

@property (nonatomic,retain)NSDictionary *paramter;

@end

@implementation ___FILEBASENAMEASIDENTIFIER___

- (id)initWithParamter:(NSDictionary *)paramterDic {
    self = [super init];
    if (self) {
        _paramter = paramterDic;
    }
    return self;
}

/**
 *  请求的url
 *
 *  @return
 */
- (NSString *)requestUrl {
    //: /qyer/startpage/banner
    return @"/xx/xx";
}

/**
 *  请求方式
 *
 *  @return return value description
 */
- (YTKRequestMethod)requestMethod {
    
    return YTKRequestMethodGet;
}

/**
 *  请求参数
 *
 *  @return return value description
 */
- (NSDictionary *)requestParamter {
    
    return _paramter;
}

/**
 *  验证服务器返回字段
 *
 *  @return return value description
 */
- (id)validatorResult {
    
    return @{
             @"xx" : [ClassName class],
             @"yy" : [ClassName class],
             @"zz" : [ClassName class]
             };
}

/**
 *  本地测试数据,联调是需要删除
 */
//-(NSDictionary *)testData{
//    return nil;
//}

@end
