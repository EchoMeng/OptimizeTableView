//
//  MXContent.h
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXRetweetContent.h"
#import "MXUser.h"

@interface MXContent : NSObject

@property (nonatomic, strong) NSString *frame;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) MXRetweetContent *retweetedStatus;

@property (nonatomic, strong) MXUser *user;

@property (nonatomic, strong) NSArray *picURLs;

@property (nonatomic, strong) NSString *createdAt;

@property (nonatomic, assign) NSInteger commentsCount;

@property (nonatomic, assign) NSInteger repostsCount;

@end
