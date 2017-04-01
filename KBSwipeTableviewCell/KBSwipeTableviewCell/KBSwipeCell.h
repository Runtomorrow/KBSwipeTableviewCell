//
//  KBSwipeCell.h
//  KBSwipeTableviewCell
//
//  Created by kobe on 2017/3/28.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  KBSwipeCellDelegate <NSObject>
- (void)resetCellCloseStatusIndexPath:(NSIndexPath *)indexPath;
@end

@interface KBSwipeCell : UITableViewCell
@property (nonatomic, weak) id<KBSwipeCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
