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
    return <#@"/xx/xx"#>;
}

/**
 *  请求方式
 *
 *  @return
 */
- (YTKRequestMethod)requestMethod {
    return <#YTKRequestMethodGet#>;
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
 *  使用热键 输入接口文档返回数据结构模板【JSON】
 *  自动生成验证返回字段方法 和 本地测试数据方法
 */
@end
