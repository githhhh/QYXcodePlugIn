//
//  CategoryGetterSetterAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/16.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "AutoGetterAchieve.h"
#import "CategoryGetterSetterAchieve.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import "Promise.h"
#import "QYClangFormat.h"

static const NSString * machsStr = @"static\\s+char\\s+const\\s+\\*\\s*const\\s+(\\w+)\\s*=\\s*\"\\w*\";{1}";

#define matcheCharDefArrKey @"kMatcheCharDefArr"
#define matcheCharKeyArrKey @"kMatcheCharKeyArr"

#define appendCharDefKey @"kAppendCharDefStr"
#define appendMethodKey @"kAppendMethodStr"

@interface CategoryGetterSetterAchieve()

@property (nonatomic,retain) LAFIDESourceCodeEditor *editor;

@property (nonatomic,retain) NSDictionary *charDefMatcheDic;

@property (nonatomic,assign) BOOL isHeaderFile;

@property (nonatomic,copy) NSString *implementationContent;

@property (nonatomic,copy) NSString *currentImpleMentationPath;

@property (nonatomic,retain) NSString *privateReadWritePropertyDef;
@end

@implementation CategoryGetterSetterAchieve

-(void)dealloc{
    NSLog(@"=CategoryGetterSetterAchieve===dealloc=");
}

-(void)createCategoryGetterSetterAction{

    self.isHeaderFile           = [[MHXcodeDocumentNavigator currentFilePath] isHeaderFilePath];

    PMKPromise *promiseStr      = [self promiseAppendCharDefAndMethodStr];
    PMKPromise *promiseInserLoc = [AutoGetterAchieve promiseInsertLoction];
    NSDictionary *promiseDic    = @{@"strDic":promiseStr,@"rang":promiseInserLoc};

    [PMKPromise when:promiseDic] .thenOn(dispatch_get_main_queue(),^id(NSDictionary *dic){
        //更新Editor
        return  [self updateCurrentEditorWith:dic];
    }).thenOn(dispatch_get_global_queue(0, 0),^(NSDictionary *dic){
        //更新.m文件
       return   [self updateImplementtationWith:dic];
    }).thenOn(dispatch_get_main_queue(),^id(NSString *updatedSource){
        //主线程写入.m文件
        if (self.isHeaderFile && !IsEmpty(updatedSource)) {
            NSError *writeError;
            BOOL isWrite = [updatedSource writeToFile:self.currentImpleMentationPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
            if (writeError || !isWrite)
                return  error(@".m写入内容失败", 0, nil);
        }
        
        //判断、添加头文件   去重。。
        if (![self.editor hasImportedHeader:@"#import <objc/runtime.h>"])
            [self.editor importHeader:@"#import <objc/runtime.h>"];

        return nil;
    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
        
        NSString *dominStr = dominWithError(err);
        [LAFIDESourceCodeEditor showAboveCaret:dominStr color:[NSColor yellowColor]];
        
    });
};


#pragma mark - promise Task
/**
 *  main_queue 获取当前.m 文件内容 和 选择内容
 *
 *  @return return value description
 */
-(PMKPromise *)promiseSource{
    
    PMKPromise *sourcePromise =
    
    dispatch_promise_on(dispatch_get_main_queue(), ^id(){
        
        self.implementationContent = self.editor.view.textStorage.string;
        
        if (self.isHeaderFile) {
            NSError *readError;
            NSString *soureString = [NSString stringWithContentsOfFile:self.currentImpleMentationPath encoding:NSUTF8StringEncoding error:&readError];
            if (readError)
                return  readError;
            self.implementationContent = soureString;
        }
        
        if (IsEmpty(self.editor.selectedText))
            return error(@"选中内容为空。。", 0, nil);
        
        NSRange range = [self.editor.selectedText rangeOfString:@"@end"];
        if (!RangIsNotFound(range))
            return error(@"选中内容不能包含@end..", 0, nil);
        
        return PMKManifold(self.implementationContent,self.editor.selectedText);
    });
    
    return sourcePromise;
}

/**
 *  拼接字符串
 *
 *  @return return value description
 */
-(PMKPromise *)promiseAppendCharDefAndMethodStr{
    
    PMKPromise *promise =
    
    [self promiseSource].thenOn(dispatch_get_global_queue(0, 0),^id(NSString *source,NSString *seleteText){
        
        //匹配已经定义的charDef
        NSError *error;
        self.charDefMatcheDic = [self matchCharDefStr:source error:&error];
        if (error)
            return error;
        
        //解析选中内容
        NSError *matchError;
        NSArray *matcheArr = [seleteText matcheGroupWith:@"@property\\s*\\((.+?)\\)\\s*(\\w+?\\s*\\*{0,1})\\s*(\\w+)\\s*;{1}" error:&matchError];
        if (matchError)
            return matchError;
        NSArray *propertyArr = [self praseMatchePropertyArr:matcheArr];
        
        return [self appendStrWithPropertyArr:propertyArr];
    });
    
    return promise;
}



/**
 *  更新文件内容
 *
 *  @param dic dic description
 *
 *  @return return value description
 */
-(PMKPromise * )updateImplementtationWith:(NSDictionary *)dic{
    PMKPromise *updateSourcePromise =
    
    [self promiseAppendReadOnlyPrivateProperty].thenOn(dispatch_get_global_queue(0, 0), ^id(NSValue *inserValue){
        if (!(self.isHeaderFile && dic)) {
            return nil;
        }
        //当前在.h 文件
        NSRange inserRange = [inserValue rangeValue];
        NSDictionary *strDic = dic[@"strDic"];
        
        NSString *charDefStr = strDic[appendCharDefKey];
        NSString *methodStr  = strDic[appendMethodKey];
        NSValue *endRangValue = dic[@"rang"];
        
        if (ArrIsEmpty(self.charDefMatcheDic)) {
            NSString *markStr = @"#pragma mark - Setter && Getter \n";
            NSString *allStr = [NSString stringWithFormat:@"%@\n%@\n%@",markStr,charDefStr,methodStr];
            //替换
            self.implementationContent = [self.implementationContent stringByReplacingCharactersInRange:[endRangValue rangeValue] withString:allStr];
        }else{
            //替换methodStr
            self.implementationContent = [self.implementationContent stringByReplacingCharactersInRange:[endRangValue rangeValue] withString:methodStr];
            
            //替换charDefStr  去掉换行
            charDefStr = [charDefStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSString *lastCharDefStr = [self.charDefMatcheDic[matcheCharDefArrKey] lastObject];
            NSString *replaceCharDefContent = [NSString stringWithFormat:@"%@\n%@",lastCharDefStr,charDefStr];
            NSRange charDefInsertRang = [self.implementationContent rangeOfString:lastCharDefStr];
            
            self.implementationContent = [self.implementationContent stringByReplacingCharactersInRange:charDefInsertRang withString:replaceCharDefContent];
        }
        //只读属性
        if (!IsEmpty(self.privateReadWritePropertyDef)&&! RangIsNotFound(inserRange)) {
            self.implementationContent = [self.implementationContent stringByReplacingCharactersInRange:inserRange withString:self.privateReadWritePropertyDef];
        }
        return self.implementationContent;
    });
    
    return updateSourcePromise;
}



-(PMKPromise *)updateCurrentEditorWith:(NSDictionary *)dic{
    
    PMKPromise *updateEditor =
    
    dispatch_promise_on(dispatch_get_main_queue(), ^id(){
        if (self.isHeaderFile) {
            return dic;
        }
        
        //当前在.m 文件
        NSDictionary *strDic = dic[@"strDic"];
        NSString *charDefStr = strDic[appendCharDefKey];
        NSString *methodStr  = strDic[appendMethodKey];
        NSValue *endRangValue = dic[@"rang"];
        
        if (ArrIsEmpty(self.charDefMatcheDic)) {
            NSString *markStr = @"#pragma mark - Setter && Getter ";
            
            NSString *allStr = [NSString stringWithFormat:@"%@\n%@\n%@",markStr,charDefStr,methodStr];
            
            [self.editor.view insertText:allStr replacementRange:[endRangValue rangeValue]];
        }else {
            [self.editor.view insertText:methodStr replacementRange:[endRangValue rangeValue]];
            
            //替换charDefStr  去掉换行
            charDefStr = [charDefStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            NSString *lastCharDefStr = [self.charDefMatcheDic[matcheCharDefArrKey]  lastObject];
            NSString *replaceCharDefContent = [NSString stringWithFormat:@"%@\n%@",lastCharDefStr,charDefStr];
            
            NSRange charDefInsertRang = [self.editor.view.textStorage.string rangeOfString:lastCharDefStr];
            if (RangIsNotFound(charDefInsertRang))
                return  error(@"匹配charDef错误。。。", 0, nil);
            
            [self.editor.view insertText:replaceCharDefContent replacementRange:charDefInsertRang];
        }
        
        return nil;
    });
    
    return updateEditor;
}

/**
 *  处理只读属性。。。
 *
 *  @return  插入Range
 */
-(PMKPromise *)promiseAppendReadOnlyPrivateProperty{
    
    PMKPromise *insertLocPromise =
    
    dispatch_promise_on(dispatch_get_global_queue(0, 0),^id(){
        
        __block NSValue *rangVaule = [NSValue valueWithRange:NSMakeRange(0, 0)];
        
        if (IsEmpty(self.privateReadWritePropertyDef) || !self.isHeaderFile)
            return rangVaule;
        
        NSString *matchClassNameStr = [self.currentImpleMentationPath currentClassName];
        if (![self.currentImpleMentationPath isCategoryFilePath])
            return rangVaule;
        
        NSArray * classNameArr = [matchClassNameStr componentsSeparatedByString:@"+"];
        if (ArrIsEmpty(classNameArr))
            return  error(@"获取分类名失败", 0, nil);
        
        NSString *originClassName = classNameArr[0];
        NSString *categroyName = classNameArr[1];
        
        //匹配私有@interface
        NSError *matchError;
        NSString *matchStr = [NSString stringWithFormat:@"@interface\\s+%@\\s*\\(\\s*\\)",originClassName];
        NSArray *matchArr = [self.implementationContent matcheStrWith:matchStr error:&matchError];
        if (matchError)
            return matchError;
        
        if (ArrIsEmpty(matchArr)) {
            //拼接。。
            self.privateReadWritePropertyDef = [NSString stringWithFormat:@"@interface %@ ( )\n%@\n\n@end\n",originClassName,self.privateReadWritePropertyDef];
            
            //匹配@implementation
            NSString *categoryClassName  = [NSString stringWithFormat:@"%@\\s*\\(\\s*%@\\s*\\)",originClassName,categroyName];
            NSString *matchStr = [NSString stringWithFormat:@"@implementation\\s+%@\\s*",categoryClassName];
            matchArr = [self.implementationContent matcheStrWith:matchStr error:&matchError];
            if (matchError)
                return matchError;
            
            NSTextCheckingResult *match = matchArr[0];
            NSRange range = [match rangeAtIndex:0];
            
            NSString *impDefStr = [self.implementationContent substringWithRange:range];
            self.privateReadWritePropertyDef = [NSString stringWithFormat:@"%@\n%@",self.privateReadWritePropertyDef,impDefStr];
            
            rangVaule = [NSValue valueWithRange:range];
        }else {
            //查找 end
            NSError *endMatchError;
            NSArray *endMatchArr = [self.implementationContent matcheStrWith:@"@end" error:&matchError];
            if (endMatchError)
                return endMatchError;
            if (!( !ArrIsEmpty(endMatchArr)&&[endMatchArr count]>1 )) {
                return  error(@"查找end位置出错啦。。", 0, nil);
            }
            NSTextCheckingResult *privateInterfaceMatch = matchArr[0];
            NSRange privateInterfaceRange = [privateInterfaceMatch rangeAtIndex:0];
            [endMatchArr enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange endRange = [match rangeAtIndex:0];
                if (endRange.location > privateInterfaceRange.location) {
                    rangVaule = [NSValue valueWithRange:endRange];
                    *stop =  YES;
                }
            }];
            self.privateReadWritePropertyDef = [self.privateReadWritePropertyDef stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.privateReadWritePropertyDef = [NSString stringWithFormat:@"%@\n\n@end",self.privateReadWritePropertyDef];
        }
        
        return rangVaule;
    });
    
    return insertLocPromise;
}

-(PMKPromise  *)appendStrWithPropertyArr:(NSArray *)ppArr{
    PMKPromise *appendPromise =
    
    [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSMutableString *allCharKeyDef = [NSMutableString stringWithCapacity:0];
        NSMutableString *allMethodsStr = [NSMutableString stringWithCapacity:0];
        
        [ppArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDictionary *ppDic = ppArr[idx];
            NSString *key = [NSString stringWithFormat:@"%@",[ppDic allKeys][0]] ;
            NSString *value = ppDic[key];
            
            //char key
            NSString *charKey = [NSString stringWithFormat:@"k%@",[value mh_capitalizedString]];
            charKey = [charKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *charKeyDef = [NSString stringWithFormat:@"static char const * const %@           = \"%@\";\n",charKey,value];
            
            if (!ArrIsEmpty(self.charDefMatcheDic) && [self.charDefMatcheDic[matcheCharKeyArrKey] containsObject:charKey]) {
                return ;
            }
            
            NSString *methodStr = [self appendMethodStrWithKeyType:key andVarName:value];
            
            [allMethodsStr appendString:methodStr];
            [allCharKeyDef appendString:charKeyDef];
        }];
        //全部重复
        if ( IsEmpty(allMethodsStr)&& IsEmpty(allCharKeyDef)){
            reject(error(@"选中内容已经有了哦。。。", 100, nil));
        }else{
            [allMethodsStr appendString:@"\n\n@end"];
            fulfill(@{appendCharDefKey:allCharKeyDef,appendMethodKey:allMethodsStr});
        }
        
    }];
    
    return  appendPromise;
}

#pragma mark - private Method
/**
 *  解析选中属性定义,提取只读属性
 *
 *  @param matcheArr matcheArr description
 *
 *  @return return value description
 */
-(NSArray *)praseMatchePropertyArr:(NSArray *)matcheArr{
    
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
    NSInteger groupCount = [matcheArr count] / 4;
    
    NSMutableString *readOnlyPropertyStr = [NSMutableString stringWithCapacity:0];
    for (int i = 0; i < groupCount; i++) {
        NSInteger keyIndex = i * 4 + 2;
        NSInteger valueIndex = keyIndex + 1;
        
        NSString *key = matcheArr[keyIndex];
        NSString *value = matcheArr[valueIndex];
        [propertyArr addObject:@{key : value}];
        
        
        NSString *propertyAttr = matcheArr[keyIndex - 1];
        if ([propertyAttr mh_containsString:@"readonly"]) {
            NSString *propertyDefStr = matcheArr[i*4];
            propertyDefStr = [propertyDefStr stringByReplacingOccurrencesOfString:@"readonly" withString:@"readwrite"];
            [readOnlyPropertyStr appendFormat:@"\n%@",propertyDefStr];
        }
    }
    if (IsEmpty(self.privateReadWritePropertyDef) && !IsEmpty(readOnlyPropertyStr)) {
        self.privateReadWritePropertyDef = [NSString stringWithString:readOnlyPropertyStr] ;
    }
    
    return  propertyArr;
}

/**
 *  匹配charDefStr
 *
 *  @param contentSource contentSource description
 *
 *  @return return value description
 */
-(NSDictionary *)matchCharDefStr:(NSString *)contentSource error:(NSError **)error{
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray *charKeyArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *charDefStrArr = [NSMutableArray arrayWithCapacity:0];
    NSError *matchError;
    NSArray *matchArr = [contentSource matcheGroupWith:@"static\\s+char\\s+const\\s+\\*\\s*const\\s+(\\w+)\\s*=\\s*\"\\w*\";{1}" error:&matchError];
    *error =  matchError;
    
    if (!ArrIsEmpty(matchArr)) {
        NSInteger groupCount = [matchArr count]/2;
        
        for (NSInteger i = 0; i < groupCount; i++) {
            NSInteger charDefIndex = i*2;
            NSInteger charKeyIndex = charDefIndex + 1;
            NSString *key = matchArr[charKeyIndex];
            key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            [charDefStrArr addObject:matchArr[charDefIndex]];
            [charKeyArr addObject:key];
        }
        
        [mDic setObject:charDefStrArr forKey:matcheCharDefArrKey];
        [mDic setObject:charKeyArr forKey:matcheCharKeyArrKey];
    }
    
    return mDic;
}



-(NSString *)appendMethodStrWithKeyType:(NSString *)key andVarName:(NSString *)value{
    
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    BOOL isObj = [key mh_containsString:@"*"];
    //Retain / Copy / Assign
    NSString *propertyAttr = @"OBJC_ASSOCIATION_RETAIN_NONATOMIC";
    if (!isObj) {
        propertyAttr = @"OBJC_ASSOCIATION_ASSIGN";
    }else{
       NSString *classNameStr =  [key substringToIndex:key.length - 1];
        classNameStr = [classNameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([classNameStr isEqualToString:@"NSString"]) {
            propertyAttr = @"OBJC_ASSOCIATION_COPY_NONATOMIC";
        }
    }
    
    NSString *charKey = [NSString stringWithFormat:@"k%@",[value mh_capitalizedString]];
    //Setter
    NSString *setterBody = [NSString stringWithFormat:@" objc_setAssociatedObject(self, &%@, %@, %@);",charKey,value,propertyAttr];
    if (!isObj)
        setterBody = [NSString stringWithFormat:@" objc_setAssociatedObject(self, &%@, @(%@), %@);",charKey,value,propertyAttr];
    
    NSString *setterStr = [NSString stringWithFormat:@"- (void)set%@:(%@)%@{\n  %@  \n}\n",[value mh_capitalizedString],key,value,setterBody];
    
    //Getter
    NSString *getterBody = [NSString stringWithFormat:@"  return objc_getAssociatedObject(self, &%@);",charKey];
    if (!isObj) {
        
        if ( [key isEqual:@"NSInteger"]) {
            getterBody = [NSString stringWithFormat:@"  return [objc_getAssociatedObject(self, &%@) integerValue];",charKey];
            
        }else if ([key isEqualToString:@"BOOL"]){
            getterBody = [NSString stringWithFormat:@"  return [objc_getAssociatedObject(self, &%@) boolValue];",charKey];
        }else if ([key isEqualToString:@"CGFloat"]){
            getterBody = [NSString stringWithFormat:@"  return [objc_getAssociatedObject(self, &%@) floatValue];",charKey];
        }else if ([key isEqualToString:@"NSRange"]){
            getterBody = [NSString stringWithFormat:@"  return [objc_getAssociatedObject(self, &%@) rangeValue];",charKey];
        }
        //other
        
    }
    NSString *getterStr = [NSString stringWithFormat:@"- (%@)%@{\n %@ \n}\n",key,value,getterBody];
    
    return  [NSString stringWithFormat:@"%@\n%@",setterStr,getterStr];
}


#pragma mark - Getter

- (NSString *)currentImpleMentationPath
{
    if (!_currentImpleMentationPath) {
        NSString *sourceFilePath = [MHXcodeDocumentNavigator currentFilePath];
        //.m path
        sourceFilePath = [sourceFilePath stringByReplacingCharactersInRange:NSMakeRange(sourceFilePath.length - 1, 1)
                                                                 withString:@"m"];
        
        _currentImpleMentationPath = sourceFilePath;
    }
    return _currentImpleMentationPath;
}


-(LAFIDESourceCodeEditor *)editor{
    if (!_editor) {
        _editor = [[LAFIDESourceCodeEditor alloc] init];
    }
    return _editor;
}

@end
