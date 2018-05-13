//
//  MXBestTableViewCell.h
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXContent.h"
#import "MXCellLayout.h"

@interface MXBestTableViewCell : UITableViewCell

@property (nonatomic, strong) MXContent *data;

@property (nonatomic, strong) MXCellLayout *layout;

- (void)draw;

- (void)clear;

- (void)releaseMemory;

@end
