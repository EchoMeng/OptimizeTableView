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


#define NameFont (14)
#define NameDetailFont (10)

@interface MXBestTableViewCell()

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIButton *headButton;

@property (nonatomic, strong) UIButton *commentButton;

@property (nonatomic, strong) UIButton *reportButton;

@property (nonatomic, strong) UIImageView *conerImageView;

@property (nonatomic, strong) MXBestLabel *titleLabel;

@property (nonatomic, strong) MXBestLabel *detailInfoLabel;

@property (nonatomic, strong) UIScrollView *mutiImageScrollView;

@property (nonatomic, assign) BOOL drawed;


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
    [_headButton addTarget:self action:@selector(haedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headButton];
    
    //评论按钮
    _commentButton = [[UIButton alloc] init];
    [_commentButton setImage:[UIImage imageNamed:@"t_comments@2x"] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(commentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_commentButton];
    
    //转发按钮
    _reportButton = [[UIButton alloc] init];
    [_reportButton setImage:[UIImage imageNamed:@"t_repost@2x"] forState:UIControlStateNormal];
    [_reportButton addTarget:self action:@selector(reportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_reportButton];
    
    //头像圆角覆盖图
    _conerImageView = [[UIImageView alloc] init];
    _conerImageView.center = self.headButton.center;
    _conerImageView.image = [UIImage imageNamed:@"corner_circle@2x.png"];
    [self.contentView addSubview:_conerImageView];
    
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
    _titleLabel.font = [UIFont systemFontOfSize:TextFontSize];
    [self.contentView addSubview:_titleLabel];
    
    
    _detailInfoLabel = [[MXBestLabel alloc] init];
    _detailInfoLabel.textColor = [UIColor grayColor];
    _detailInfoLabel.font = [UIFont systemFontOfSize:DetailFontSize];
    [self.contentView addSubview:_detailInfoLabel];
}

- (void)draw {
    if (self.drawed) {
        return;
    }
    _drawed = YES;
    //这部分将整个背景合成一张图片显示
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //这里绘制背景颜色填充
        CGRect rect = self.layout.frame;
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1] set];
        CGContextFillRect(context, rect);
        //主文本部分颜色
        [[UIColor whiteColor] set];
        CGContextFillRect(context, self.layout.rect);
        
        //如果有详情部分，设置其背景颜色
        if (self.data.retweetedStatus) {
            [kColorLightGray setFill];
            [[UIColor grayColor] setStroke];
            CGContextSetLineWidth(context, 0.3);
            CGContextAddRect(context, self.layout.subRect);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
        //绘制用户名部分
        {
            [self.data.user.name drawInContext:context withPosition:self.layout.nameOrigin andFont:[UIFont systemFontOfSize:NameFont] andTextColor:[UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1] andHeight:rect.size.height];
            
            CGFloat fromHeight = rect.size.height;
            
            [self.data.createdAt drawInContext:context withPosition:self.layout.sunNameOrigin andFont:[UIFont systemFontOfSize:NameDetailFont] andTextColor:[UIColor grayColor] andHeight:fromHeight];
        }
        //绘制评论转发部分。这里直接把转评部分直接绘制为背景图的一部分，无法响应点击事件，不能算是一个好办法吧。
        //UIImage使用drawInRect方法的绘制十分耗时，导致整个背景图同步到主线程显示的时间延迟，因此这里没有使用这个方法
        {
            [kColorLightGray setFill];
            [[UIColor grayColor] setStroke];
            CGContextSetLineWidth(context, 0.3);
            CGContextAddRect(context, self.layout.commentRect);
            CGContextDrawPath(context, kCGPathFillStroke);
//            [[UIImage imageNamed:@"t_comments@2x"] drawInRect:self.layout.commentLogoFrame blendMode:kCGBlendModeNormal alpha:1.0];
//            [[UIImage imageNamed:@"t_repost@2x"] drawInRect:self.layout.reportLogoFrame blendMode:kCGBlendModeNormal alpha:1.0];
            if (self.data.commentsCount > 0) {
                NSString *commentNumStr = [NSString stringWithFormat:@"%ld", (long)self.data.commentsCount];
                [commentNumStr drawInContext:context withPosition:self.layout.commentTextOrigin andFont:[UIFont systemFontOfSize:DetailFontSize] andTextColor:[UIColor grayColor] andHeight:rect.size.height];
            }
            if (self.data.repostsCount > 0) {
                NSString *reportNumStr = [NSString stringWithFormat:@"%ld", (long)self.data.repostsCount];
                [reportNumStr drawInContext:context withPosition:self.layout.reportTextOrigin andFont:[UIFont systemFontOfSize:DetailFontSize] andTextColor:[UIColor grayColor] andHeight:rect.size.height];
            }
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
    [self drawText];
    [self loadPics];
}

- (void)loadPics {
    NSInteger count = self.data.picURLs.count;
    if (count <= 0) {
        self.mutiImageScrollView.frame = CGRectZero;
        self.mutiImageScrollView.hidden = YES;
        return;
    }
    for (UIImageView *imageView in self.mutiImageScrollView.subviews) {
        [imageView removeFromSuperview];
    }
    self.mutiImageScrollView.frame = self.layout.picScrollViewFrame;
    self.mutiImageScrollView.contentSize = CGSizeMake(HeadLeftMargin * 2 + PublicMargin * (count - 1) + PicWidth * count, 0);
    self.mutiImageScrollView.backgroundColor = kColorLightGray;
    self.mutiImageScrollView.layer.borderWidth = 0.3;
    self.mutiImageScrollView.layer.borderColor = [UIColor grayColor].CGColor;
    self.mutiImageScrollView.hidden = NO;
    
    for (int i = 0; i < count; i++) {
        UIImageView *picView = [[UIImageView alloc] init];
        picView.contentMode = UIViewContentModeScaleAspectFill;
        picView.backgroundColor = [UIColor grayColor];
        picView.clipsToBounds = YES;
        picView.frame = CGRectMake(HeadLeftMargin + PublicMargin * i + PicWidth * i, PublicMargin, PicWidth, PicHeight);
        [self.mutiImageScrollView addSubview:picView];
        [picView sd_setImageWithURL:self.data.picURLs[i]];
    }
}

- (void)drawText {
    if (self.titleLabel == nil || self.detailInfoLabel == nil) {
        [self addContentLabel];
    }
    self.titleLabel.frame = self.layout.textRect;
    self.titleLabel.text = self.data.text;
    if (self.data.retweetedStatus) {
        self.detailInfoLabel.frame = self.layout.subTextRect;
        self.detailInfoLabel.text = [NSString stringWithFormat:@"@%@: %@", self.data.retweetedStatus.user.name, self.data.retweetedStatus.text];
        self.detailInfoLabel.hidden = NO;
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
    _layout = [[MXCellLayout alloc] init];
    _layout.data = data;
    self.headButton.frame = _layout.headFrame;
    self.conerImageView.frame = _layout.cornerFrame;
    self.conerImageView.center = _headButton.center;
    self.commentButton.frame = _layout.commentLogoFrame;
    self.reportButton.frame = _layout.reportLogoFrame;
    _data = data;
}

- (void)setFrame:(CGRect)frame {
    CGRect newFrame = frame;
    newFrame.size.height -= 3;
    [super setFrame:newFrame];
}

#pragma event
- (void)haedBtnClick:(UIButton *)btn {
    NSLog(@"%s", __func__);
}

- (void)commentBtnClick:(UIButton *)btn {
    NSLog(@"%s", __func__);
}

- (void)reportBtnClick:(UIButton *)btn {
    NSLog(@"%s", __func__);
}

@end
