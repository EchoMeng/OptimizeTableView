//
//  MXContent.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXContent.h"
#import <MJExtension.h>
#import <UIKit/UIKit.h>

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

- (void)setTextRect:(NSString *)textRect {
    CGRect rect = CGRectFromString(textRect);
    rect.size.width = [UIScreen mainScreen].bounds.size.width - 2 * rect.origin.x;
    NSString *rectString = NSStringFromCGRect(rect);
    _textRect = rectString;
}

@end
