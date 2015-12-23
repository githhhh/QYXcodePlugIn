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

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _didSelectItemSubject = [[RACSubject alloc] init];
        
    }
    return self;
}


#pragma mark - UICollectionView DataSource
/**
 *  每个CollectionView有多少个Section
 *
 *  @param collectionView
 *
 *  @return
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

/**
 *  每个Section里面有多少个Cell
 *
 *  @param collectionView
 *  @param section
 *
 *  @return
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}


/**
 *  每个cell的宽度和高度
 *
 *  @param collectionView
 *  @param collectionViewLayout
 *  @param indexPath
 *
 *  @return
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return <#CGSizeZero#>
}

/**
 *  cell，上、左、下、右的间距
 *
 *  @param collectionView
 *  @param collectionViewLayout
 *  @param section
 *
 *  @return
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return <#UIEdgeInsetsZero#>;
}

/**
 *  Cell之间的最小间距
 *
 *  @param collectionView
 *  @param collectionViewLayout
 *  @param section
 *
 *  @return
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return <#0#>;
}

/**
 *  行之间的最小间距
 *
 *  @param collectionView
 *  @param collectionViewLayout
 *  @param section
 *
 *  @return
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return <#0#>;
}

/**
 *  每个Cell具体显示的内容
 *
 *  @param collectionView
 *  @param indexPath
 *
 *  @return
 */

/*
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
    // Configure the cell...
 
    return cell;
}*/

#pragma mark - UICollectionViewDelegate
/**
 *  选中某个cell，触发的方法
 *
 *  @param collectionView
 *  @param indexPath
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.didSelectItemSubject sendNext:indexPath];
}


@end
