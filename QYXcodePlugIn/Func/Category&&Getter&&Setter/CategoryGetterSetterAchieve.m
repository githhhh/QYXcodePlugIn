//
//  CategoryGetterSetterAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/16.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "CategoryGetterSetterAchieve.h"
#import "Promise.h"
#import "MHXcodeDocumentNavigator.h"
#import "AutoGetterAchieve.h"
#import "NSString+Extensions.h"
#import "QYClangFormat.h"

@interface CategoryGetterSetterAchieve()

@property (nonatomic,retain) LAFIDESourceCodeEditor *editor;
@end

@implementation CategoryGetterSetterAchieve


-(void)createCategoryGetterSetterAction{

    PMKPromise *promiseMethodStr = [self promiseMethodStr];
    PMKPromise *promiseInserLoc =  [AutoGetterAchieve promiseInsertLoction];
    
    NSDictionary *promiseDic = @{@"str":promiseMethodStr,@"rang":promiseInserLoc};
    
    [PMKPromise when:promiseDic].thenOn(dispatch_get_main_queue(),^(NSDictionary *dic){
        
        NSValue *rangValue = dic[@"rang"];

        if (![[MHXcodeDocumentNavigator currentFilePath] isHeaderFilePath]) {
            
            [self.editor.view insertText:dic[@"str"] replacementRange:[rangValue rangeValue]];
            
        }else {
            
            [self upateSourceContentWith:dic[@"str"] andReplaceRange:[rangValue rangeValue]];
        }
        
    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
        NSString *dominStr = dominWithError(err);
        [self.editor showAboveCaret:dominStr color:[NSColor yellowColor]];
    });

    
};





-(void)upateSourceContentWith:(NSString *)content andReplaceRange:(NSRange)range{
    
    dispatch_promise_on(dispatch_get_global_queue(0, 0), ^id(){
        
        NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];
        //读取.m 内容
        currentFilePath =
        [currentFilePath stringByReplacingCharactersInRange:NSMakeRange(currentFilePath.length - 1, 1) withString:@"m"];
        
        NSString *soureString = [NSString stringWithContentsOfFile:currentFilePath encoding:NSUTF8StringEncoding error:nil];
        if (!soureString||soureString.length == 0)
            return error(@"读取文件失败", 0, nil);

        //替换
        soureString = [soureString stringByReplacingCharactersInRange:range withString:content];
        return  PMKManifold(soureString,currentFilePath);
        
    }).thenOn(dispatch_get_main_queue(),^(NSString *soureString,NSString *sourceFilePath){
        BOOL isWrite = [soureString writeToFile:sourceFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if (!isWrite)
            @throw  error(@".m写入内容失败", 0, nil);
        //添加头文件
        if (![self.editor hasImportedHeader:@"#import <objc/runtime.h>"])
            [self.editor importHeader:@"#import <objc/runtime.h>"];
    });
    
}





-(PMKPromise *)promiseMethodStr{
    PMKPromise *promise =
    
    dispatch_promise_on(dispatch_get_main_queue(),^id(){
        return self.editor.selectedText;
    }).thenOn(dispatch_get_global_queue(0, 0), ^id (NSString *selectedText){
        NSArray *ppArr = [AutoGetterAchieve MatcheSelectText:selectedText];
        if ([ppArr count] == 0)
            return  error(@"解析选中property错误.....", 0, nil);
    
        NSString *allMethodStr = [self appendMethodWithPropertyArr:ppArr];
       
        // 匹配Mark
        NSString *regexPragma = @"#pragma mark - Setter&&Getter\n";
        NSArray *markMatches = [self.editor.view.textStorage.string matcheStrWith:@"Setter&&Getter"];
        if (ArrIsEmpty(markMatches))
            allMethodStr = [NSString stringWithFormat:@"%@\n%@",regexPragma,allMethodStr];
        
        //formate
        return [QYClangFormat promiseClangFormatSourceCode:allMethodStr];
    });
    
    return promise;
}




#pragma mark - private Methode
-(NSString *)appendMethodWithPropertyArr:(NSArray *)ppArr{
    
    NSMutableString *allMethodsStr = [NSMutableString stringWithCapacity:0];
    NSMutableString *allCharKeyDef = [NSMutableString stringWithCapacity:0];
    
    [ppArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSDictionary *ppDic = ppArr[idx];
        NSString *key = [ppDic allKeys][0];
        NSString *value = ppDic[key];

        
       NSString *propertyAttr = @"OBJC_ASSOCIATION_RETAIN_NONATOMIC";
        if ([key isEqualToString:@"NSString"]) {
            propertyAttr = @"OBJC_ASSOCIATION_COPY_NONATOMIC";
        }
        
        //char key
        NSString *charKey = [NSString stringWithFormat:@"k%@",[value capitalizedString]];
        NSString *charKeyDef = [NSString stringWithFormat:@"static char const * const %@           = \"%@\";\n",charKey,value];
        
        NSString *setterStr = [NSString stringWithFormat:@"- (void)set%@:(%@ *)%@{\n   objc_setAssociatedObject(self, &%@, %@, %@);\n}\n",[value capitalizedString],key,value,charKey,value,propertyAttr];
        
        NSString *getterStr = [NSString stringWithFormat:@"- (%@*)%@\n{\n    return objc_getAssociatedObject(self, &%@);\n}\n",key,value,charKey];
        
        [allCharKeyDef appendString:charKeyDef];
        [allMethodsStr appendString:setterStr];
        [allMethodsStr appendString:getterStr];
    }];
    
    
    [allMethodsStr appendString:@"\n\n@end"];
    
    return [NSString stringWithFormat:@"%@\n%@",allCharKeyDef,allMethodsStr];
}


-(LAFIDESourceCodeEditor *)editor{
    if (!_editor) {
        _editor = [[LAFIDESourceCodeEditor alloc] init];
    }
    return _editor;
}

@end
