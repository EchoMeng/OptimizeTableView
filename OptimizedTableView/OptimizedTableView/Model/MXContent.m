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
                 @"retweetedStatus" : @"retweeted_status",
                 @"createdAt" : @"created_at",
                 @"picURLs" : @"pic_urls",
                 @"commentsCount" : @"comments_count",
                 @"repostsCount" : @"reposts_count"
                 };
    }];
    [MXContent mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"retweetedStatus" : @"MXRetweetContent",
                 @"user" : @"MXUser"
                 };
    }];
}

- (void)setFrame:(NSString *)frame {
    CGRect rect = CGRectFromString(frame);
    rect.size.width = [UIScreen mainScreen].bounds.size.width;
    NSString *rectString = NSStringFromCGRect(rect);
    _frame = rectString;
}

- (void)setCreatedAt:(NSString *)createdAt {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    NSDate *date = [inputFormatter dateFromString:createdAt];
    
    NSDateFormatter *outPutFormatter = [[NSDateFormatter alloc] init];
    outPutFormatter.dateFormat = @"HH:mm:ss dd MMM yyyy";
    NSString *dateStr = [outPutFormatter stringFromDate:date];
    _createdAt = dateStr;
}

@end
