//
//  MXRetweetContent.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/8.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXRetweetContent.h"


@implementation MXRetweetContent

- (void)setTextRect:(NSString *)textRect {
    CGRect rect = CGRectFromString(textRect);
    rect.size.width = [UIScreen mainScreen].bounds.size.width - 2 * rect.origin.x;
    NSString *rectString = NSStringFromCGRect(rect);
    _textRect = rectString;
    
    CGFloat frameWidth = rect.size.width + 2 * rect.origin.x;
    CGRect frame = CGRectMake(0, rect.origin.y - 10, frameWidth, rect.size.height);
    _frame = frame;
}

@end
