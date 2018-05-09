//
//  MXCellLayout.h
//  OptimizedTableView
//
//  Created by mac on 2018/5/9.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MXContent.h"

@interface MXCellLayout : NSObject

@property (nonatomic, assign) CGRect headFrame;

@property (nonatomic, assign) CGRect cornerFrame;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) CGRect textRect;

@property (nonatomic, assign) CGRect subTextRect;

@property (nonatomic, assign) CGRect subRect;

@property (nonatomic, assign) CGRect picFrame;

@property (nonatomic, assign) CGPoint nameOrigin;

@property (nonatomic, assign) CGPoint sunNameOrigin;

@property (nonatomic, strong) MXContent *data;

@end
