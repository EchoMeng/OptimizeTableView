//
//  MXRetweetContent.h
//  OptimizedTableView
//
//  Created by mac on 2018/5/8.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MXUser.h"

@interface MXRetweetContent : NSObject

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) MXUser *user;

@end
