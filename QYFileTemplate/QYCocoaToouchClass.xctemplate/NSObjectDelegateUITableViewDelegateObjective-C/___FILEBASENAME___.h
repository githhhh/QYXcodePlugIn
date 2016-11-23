// ListViewDelegate
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

___IMPORTHEADER_cocoaTouchSubclass___

@class RACSubject;

@interface ___FILEBASENAMEASIDENTIFIER___ : ___VARIABLE_cocoaTouchSubclass___<UITableViewDataSource, UITableViewDelegate>

/**
 *  数据源
 */
@property (strong, nonatomic) NSMutableArray *dataSource;

/**
 *  点击列表触发的Subject
 */
@property (strong, nonatomic) RACSubject *didSelectItemSubject;


@end
