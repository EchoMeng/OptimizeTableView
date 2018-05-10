//
//  MXCellLayout.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/9.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXCellLayout.h"
#import "MXBestLabel.h"

#define TextLRMargin (15)
#define HeadTopMargin (15)
#define HeadLeftMargin (15)
#define HeadWH (40)
#define NameTopMargin (3)
#define PublicMargin (10)

@implementation MXCellLayout

- (void)setData:(MXContent *)data {
    if (!CGRectEqualToRect(_frame, CGRectZero)) {
        return;
    }
    _data = data;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    //头像frame
    _headFrame = CGRectMake(HeadLeftMargin, HeadTopMargin, HeadWH, HeadWH);
    
    //圆角遮盖图片size
    _cornerFrame = CGRectMake(0, 0, HeadWH+5, HeadWH+5);
    
    //用户名origin
    _nameOrigin = CGPointMake(_headFrame.origin.x + HeadWH + PublicMargin, _headFrame.origin.y + NameTopMargin);
    
    //发布时间等origin,这个计算还需要琢磨一下怎么算
    _sunNameOrigin = CGPointMake(_nameOrigin.x, _nameOrigin.y + 20);
    
    //主文本frame
    _textRect = [self.data.text boundingRectWithSize:CGSizeMake(screenWidth - HeadLeftMargin * 2, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TextFontSize]} context:nil];
    _textRect.origin.x = HeadLeftMargin;
    _textRect.origin.y = _headFrame.origin.y + HeadWH + HeadLeftMargin;
    _rect = _textRect;
    _rect.origin.x = 0;
    _rect.size.width = [UIScreen mainScreen].bounds.size.width;
    
    if (self.data.retweetedStatus) {
        //detail文本frame
        _subTextRect = [self.data.retweetedStatus.text boundingRectWithSize:CGSizeMake(screenWidth - HeadLeftMargin * 2, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:TextFontSize]} context:nil];
        _subTextRect.origin.x = HeadLeftMargin;
        _subTextRect.origin.y = _textRect.origin.y + _textRect.size.height + PublicMargin;
        
        //detail文本部分框的frame
        _subRect = _subTextRect;
        _subRect.origin.x = 0;
        _subRect.size.width = screenWidth;
    }

    
    
    _frame = CGRectMake(0, 0, screenWidth, _headFrame.size.height + PublicMargin + _textRect.size.height + PublicMargin + _subRect.size.height + PublicMargin + _picFrame.size.height + PublicMargin);
}

@end
