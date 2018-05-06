//
//  MXBestLabel.h
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXBestLabel : UIView

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) NSTextAlignment textAlignment;

- (void)clear;


@end
