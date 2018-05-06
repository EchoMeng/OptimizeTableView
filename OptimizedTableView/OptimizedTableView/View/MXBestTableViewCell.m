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

#define HeadTopMargin (15)
#define HeadLeftMargin (15)
#define HeadWH (40)
#define DetailFontSize (16)

@interface MXBestTableViewCell()

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIButton *headButton;

@property (nonatomic, strong) UIImageView *conerImageView;

@property (nonatomic, strong) UIView *topLine;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *detailInfoLabel;

@property (nonatomic, strong) UIScrollView *mutiImageScrollView;

@end

@implementation MXBestTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews {
    //背景图,确保在最底层
    _bgImageView = [[UIImageView alloc] init];
    [self.contentView insertSubview:_bgImageView atIndex:0];
    
    //头像按钮
    _headButton = [[UIButton alloc] init];
    _headButton.frame = CGRectMake(HeadTopMargin, HeadLeftMargin, HeadWH, HeadWH);
    _headButton.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_headButton];
    
    //头像圆角覆盖图
    _conerImageView = [[UIImageView alloc] init];
    _conerImageView.frame = CGRectMake(0, 0, HeadWH+5, HeadWH+5);
    _conerImageView.center = self.headButton.center;
    _conerImageView.image = [UIImage imageNamed:@"corner_circle@2x.png"];
    [self.contentView addSubview:_conerImageView];
    
    //分割线
    _topLine = [[UIView alloc] init];
    CGRect frame = CGRectFromString(self.data.frame);
    _topLine.frame = CGRectMake(0, frame.size.height - 0.5, [UIScreen screenWidth], 0.5);
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
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectFromString(self.data.textRect);
    _titleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_titleLabel];
    
    _detailInfoLabel = [[UILabel alloc] init];
    _detailInfoLabel.frame = CGRectFromString(self.data.subTextRect);
    _detailInfoLabel.textColor = [UIColor grayColor];
    _detailInfoLabel.font = [UIFont systemFontOfSize:DetailFontSize];
    [self.contentView addSubview:_detailInfoLabel];
}

- (void)draw {
    
}

- (void)clear {
    
}

- (void)releaseMemory {
    
}

@end
