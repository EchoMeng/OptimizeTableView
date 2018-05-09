//
//  MXBestTableViewCell.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXBestTableViewCell.h"
#import "UIScreen+Additions.h"
#import "UIView+Additions.h"
#import <UIImageView+WebCache.h>
#import "MXBestLabel.h"
#import "NSString+Additions.h"
#import "MXCellLayout.h"

#define NameFont (14)
#define NameDetailFont (10)

@interface MXBestTableViewCell()

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIButton *headButton;

@property (nonatomic, strong) UIImageView *conerImageView;

@property (nonatomic, strong) UIView *topLine;

@property (nonatomic, strong) MXBestLabel *titleLabel;

@property (nonatomic, strong) MXBestLabel *detailInfoLabel;

@property (nonatomic, strong) UIScrollView *mutiImageScrollView;

@property (nonatomic, assign) BOOL drawed;

@property (nonatomic, strong) MXCellLayout *layout;

@end

@implementation MXBestTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setUpSubViews {
    //背景图,确保在最底层
    _bgImageView = [[UIImageView alloc] init];
    [self.contentView insertSubview:_bgImageView atIndex:0];
    
    //头像按钮
    _headButton = [[UIButton alloc] init];
    _headButton.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_headButton];
    
    //头像圆角覆盖图
    _conerImageView = [[UIImageView alloc] init];
    _conerImageView.center = self.headButton.center;
    _conerImageView.image = [UIImage imageNamed:@"corner_circle@2x.png"];
    [self.contentView addSubview:_conerImageView];
    
    //分割线
    _topLine = [[UIView alloc] init];
    //    CGRect frame = CGRectFromString(self.data.frame);
    //    _topLine.frame = CGRectMake(0, frame.size.height - 0.5, [UIScreen screenWidth], 0.5);
    _topLine.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:_topLine];
    
    [self addContentLabel];
    
    //多图下展示图片的滚动视图
    _mutiImageScrollView = [[UIScrollView alloc] init];
    _mutiImageScrollView.scrollsToTop = NO;
    _mutiImageScrollView.showsVerticalScrollIndicator = NO;
    _mutiImageScrollView.showsHorizontalScrollIndicator = NO;
    _mutiImageScrollView.hidden = YES;
    [self.contentView addSubview:_mutiImageScrollView];
}

- (void)addContentLabel {
    //避免重用问题，每次都要重新创建新的label
    if (_titleLabel) {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }
    if (_detailInfoLabel) {
        [_detailInfoLabel removeFromSuperview];
        _detailInfoLabel = nil;
    }
    
    _titleLabel = [[MXBestLabel alloc] init];
    _titleLabel.textColor = [UIColor grayColor];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    //    _titleLabel.text = self.data.text;
    [self.contentView addSubview:_titleLabel];
    
    
    _detailInfoLabel = [[MXBestLabel alloc] init];
    _detailInfoLabel.textColor = [UIColor grayColor];
    _detailInfoLabel.font = [UIFont systemFontOfSize:12];
    //    _detailInfoLabel.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    [self.contentView addSubview:_detailInfoLabel];
}

- (void)draw {
    if (self.drawed) {
        return;
    }
    _drawed = YES;
    [self drawText];
    //这部分将整个背景合成一张图片显示
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //这里绘制背景颜色填充
        CGRect rect = CGRectFromString(self.data.frame);
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1] set];
        CGContextFillRect(context, rect);
        //如果有详情部分，设置其背景颜色
        if (self.data.retweetedStatus) {
            [[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1] set];
            CGContextFillRect(context, self.layout.subRect);
        }
        //绘制用户名部分
        {
            [self.data.user.name drawInContext:context withPosition:self.layout.nameOrigin andFont:[UIFont systemFontOfSize:NameFont] andTextColor:[UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1] andHeight:rect.size.height];
            
            CGFloat fromHeight = rect.size.height;
            
            [self.data.createdAt drawInContext:context withPosition:self.layout.sunNameOrigin andFont:[UIFont systemFontOfSize:NameDetailFont] andTextColor:[UIColor grayColor] andHeight:fromHeight];
        }
        
        
        //获取截图
        UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
        //关闭上下文
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bgImageView.frame = rect;
            self.bgImageView.image = nil;
            self.bgImageView.image = temp;
        });
    });
    
}

- (void)drawText {
    if (self.titleLabel == nil || self.detailInfoLabel == nil) {
        [self addContentLabel];
    }
    self.titleLabel.frame = self.layout.textRect;
    self.titleLabel.text = self.data.text;
    if (self.data.retweetedStatus) {
        self.detailTextLabel.frame = self.layout.subTextRect;
        self.detailInfoLabel.text = self.data.retweetedStatus.text;
        self.detailInfoLabel.hidden = NO;
    } else {
        self.detailTextLabel.frame = CGRectZero;
        self.detailTextLabel.text = nil;
        self.detailTextLabel.hidden = YES;
    }
}

- (void)clear {
    if (!_drawed) {
        return;
    }
    [self.titleLabel clear];
    if (!self.detailInfoLabel.hidden) {
        self.detailInfoLabel.hidden = YES;
        [self.detailInfoLabel clear];
    }
    self.bgImageView.frame = CGRectZero;
    self.bgImageView.image = nil;
    for (UIImageView *imageView in self.mutiImageScrollView.subviews) {
        if (!imageView.hidden) {
            [imageView sd_cancelCurrentAnimationImagesLoad];
        }
    }
    if (self.mutiImageScrollView.contentOffset.x != 0) {
        [self.mutiImageScrollView setContentOffset:CGPointZero];
    }
    self.mutiImageScrollView.hidden = YES;
    self.drawed = NO;
}

- (void)releaseMemory {
    [self clear];
    [super removeFromSuperview];
}

- (void)setData:(MXContent *)data {
    self.layout.data = data;
    self.headButton.frame = self.layout.headFrame;
    self.conerImageView.frame = self.layout.cornerFrame;
    self.conerImageView.center = self.headButton.center;
    _data = data;
}

- (void)setFrame:(CGRect)frame {
    CGRect newFrame = frame;
    newFrame.size.height -= 3;
    [super setFrame:newFrame];
}

- (MXCellLayout *)layout {
    if (!_layout) {
        _layout = [[MXCellLayout alloc] init];
    }
    return _layout;
}

@end
