//
//  NSString+Extensions.m
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)
- (BOOL)mh_containsString:(NSString *)string {
	return [self rangeOfString:string].location != NSNotFound;
}

- (NSString *)mh_stringByRemovingWhitespacesAndNewlines {
	NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
	return [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (BOOL)mh_isAlphaNumeric {
	NSCharacterSet *unwantedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	return [self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound;
}

- (BOOL)mh_isWhitespaceOrNewline {
	NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
	string = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	return string.length == 0;
}



-(NSArray *)matcheStrWith:(NSString *)regex{
    if (!(regex&&regex.length>0)||!(self&&self.length>0)) {
        return nil;
    }
    
    
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&error];
    
    // 对str字符串进行匹配
    NSArray *matches = [regular matchesInString:self
                                        options:0
                                          range:NSMakeRange(0, self.length)];
    if (error) {
        return nil;
    }
    
    return matches;
}


-(NSArray *)matcheGroupWith:(NSString *)regex{
    NSMutableArray *groupContentArr = [NSMutableArray arrayWithCapacity:0];

    if (!(regex&&regex.length>0)||!(self&&self.length>0)) {
        return groupContentArr;
    }
    
    
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&error];
    
    // 对str字符串进行匹配
    NSArray *matches = [regular matchesInString:self
                                        options:0
                                          range:NSMakeRange(0, self.length)];
    if (error) {
        return groupContentArr;
    }
    if (!(matches&&[matches count]>0)) {
        return groupContentArr;
    }
    // 遍历匹配后的每一条记录
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0;i<match.numberOfRanges;i++) {
            NSRange range = [match rangeAtIndex:i];
            NSString *mStr = [self substringWithRange:range];
            [groupContentArr addObject:mStr];
        }
        
    }

    
    return groupContentArr;
}

@end
