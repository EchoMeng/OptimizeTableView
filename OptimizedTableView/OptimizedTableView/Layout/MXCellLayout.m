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
#define HeadWH (40)
#define NameTopMargin (3)
#define CommentHeight (43)
#define LogoWH (20)

@implementation MXCellLayout

- (void)setData:(MXContent *)data {
    if (!CGRectEqualToRect(_frame, CGRectZero)) {
        return;
    }
    _data = data;
    
    //头像frame
    _headFrame = CGRectMake(HeadLeftMargin, HeadTopMargin, HeadWH, HeadWH);
    
    //圆角遮盖图片size
    _cornerFrame = CGRectMake(0, 0, HeadWH+5, HeadWH+5);
    
    //用户名origin
    _nameOrigin = CGPointMake(_headFrame.origin.x + HeadWH + PublicMargin, _headFrame.origin.y + NameTopMargin);
    
    //发布时间等origin,这个计算还需要琢磨一下怎么算
    _sunNameOrigin = CGPointMake(_nameOrigin.x, _nameOrigin.y + 20);
    
    //主文本frame
    NSMutableParagraphStyle *myStyle = [[NSMutableParagraphStyle alloc] init];
    myStyle.lineSpacing = LineSpace;
    myStyle.maximumLineHeight = MaxLineHeight;
    myStyle.minimumLineHeight = MinLineHeight;
    myStyle.lineBreakMode = NSTextAlignmentLeft;
    _textRect = [self.data.text boundingRectWithSize:CGSizeMake(ScreenWidth - HeadLeftMargin * 2, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TextFontSize], NSParagraphStyleAttributeName : myStyle} context:nil];
    
    _textRect.origin.x = HeadLeftMargin;
    _textRect.origin.y = _headFrame.origin.y + HeadWH + HeadLeftMargin;
    _rect = _textRect;
    _rect.origin.x = 0;
    _rect.origin.y -= 9;
    _rect.size.height += 10;
    _rect.size.width = [UIScreen mainScreen].bounds.size.width;
    
    if (self.data.retweetedStatus) {
        //detail文本frame
        _subTextRect = [self.data.retweetedStatus.text boundingRectWithSize:CGSizeMake(ScreenWidth - HeadLeftMargin * 2, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:DetailFontSize], NSParagraphStyleAttributeName : myStyle} context:nil];
        _subTextRect.origin.x = HeadLeftMargin;
        _subTextRect.origin.y = _textRect.origin.y + _textRect.size.height + PublicMargin;
        
        //detail文本部分框的frame
        _subRect = _subTextRect;
        _subRect.origin.x = 0;
        _subRect.origin.y -= 5;
        _subRect.size.height += 10;
        _subRect.size.width = ScreenWidth;
    } else {
        _subRect = CGRectZero;
    }
    
    //图片
    if (self.data.picURLs.count > 0) {
        CGFloat picScrollY = MAX(CGRectGetMaxY(_subRect), CGRectGetMaxY(_textRect));
        _picScrollViewFrame = CGRectMake(0, picScrollY + PublicMargin, ScreenWidth, ScrollViewHeight);
    } else {
        _picScrollViewFrame = CGRectZero;
    }
    
    //评论和转发
    CGFloat tempY = MAX(CGRectGetMaxY(_textRect), CGRectGetMaxY(_subRect));
    CGFloat commentY = MAX(tempY, CGRectGetMaxY(_picScrollViewFrame)) + PublicMargin;
    _commentRect = CGRectMake(0, commentY, ScreenWidth, CommentHeight);
    
    _commentLogoFrame = CGRectMake(ScreenWidth - 60, commentY + PublicMargin, LogoWH, LogoWH);
    _reportLogoFrame = CGRectMake(ScreenWidth - 120, commentY + PublicMargin, LogoWH, LogoWH);
    if (self.data.commentsCount > 0) {
        _commentTextOrigin = CGPointMake(CGRectGetMaxX(_commentLogoFrame) + 3, _commentLogoFrame.origin.y + 3);
    } else {
        _commentTextOrigin = CGPointZero;
    }
    if (self.data.repostsCount > 0) {
        _reportTextOrigin = CGPointMake(CGRectGetMaxX(_reportLogoFrame) + 3, _reportLogoFrame.origin.y + 3);
    } else {
        _reportTextOrigin = CGPointZero;
    }

    CGFloat frameHeight = HeadTopMargin + _headFrame.size.height + PublicMargin + _textRect.size.height + PublicMargin + (_subRect.size.height>0 ?  (_subRect.size.height + PublicMargin):0) + (_picScrollViewFrame.size.height>0?(_picScrollViewFrame.size.height + PublicMargin):0) + CommentHeight;
    _frame = CGRectMake(0, 0, ScreenWidth, frameHeight);
}

@end
