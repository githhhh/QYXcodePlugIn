//
//  TTT.m
//  QYER
//
//  Created by 唐斌 on 15/9/24.
//  Copyright © 2015年 QYER. All rights reserved.
//

#import "TTT.h"

@interface TTT ()

@property(nonatomic, retain) NSDictionary *paramter;

@end

@implementation TTT

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
//- (id)validatorResult {
//
//    return @{
//             @"xx" : [NSString class],
//             @"yy" : [NSString class],
//             @"zz" : [NSString class]
//             };
//}

/**
 *  本地测试数据,联调是需要删除
 */
//-(NSDictionary *)testData{
//    return nil;
//}

- (id)validatorResult {
  return @[
    @{
      @"id" : [NSNumber class],
      @"title" : [NSString class],
      @"price" : [NSString class],
      @"priceoff" : [NSString class],
      @"photo" : [NSString class]
    }
  ];
}

- (NSDictionary *)testData {
  return @{
    @"status" : @(1),
    @"data" : @[
      @{
        @"id" : @(1001),
        @"title" : @"成都直飞清迈含税机票",
        @"price" : @"1229",
        @"priceoff" : @"4.5折",
        @"photo" : @"http://www.qyer.com/img....."
      },
      @{
        @"id" : @(1002),
        @"title" : @"成都直飞清迈含税机票",
        @"price" : @"1229",
        @"priceoff" : @"4.5折",
        @"photo" : @"http://www.qyer.com/img....."
      }
    ],
    @"info" : @"",
    @"times" : @(0)
  };
}

@end
