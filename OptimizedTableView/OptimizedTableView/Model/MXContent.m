//
//  MXContent.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXContent.h"
#import <MJExtension.h>

@implementation MXContent

+ (void)load {
    [NSObject mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"retweetedStatus" : @"retweeted_status"
                 };
    }];
    [MXContent mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"retweetedStatus" : @"MXRetweetContent",
                 @"user" : @"MXUser"
                 };
    }];
}

@end
