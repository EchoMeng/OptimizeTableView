//
//  MXBestTableViewCell.h
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXContent.h"

@interface MXBestTableViewCell : UITableViewCell

@property (nonatomic, strong) MXContent *data;

- (void)draw;

- (void)clear;

- (void)releaseMemory;

@end
