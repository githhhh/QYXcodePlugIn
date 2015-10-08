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
    return <#@"/xx/xx"#>;
}

/**
 *  请求方式
 *
 *  @return return value description
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
 *  快捷键 control+S 输入接口文档返回数据结构模板【JSON】
 *  自动生成验证返回字段方法 和 本地测试数据方法
 */
@end
