//
//  MXBestLabel.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXBestLabel.h"

@interface MXBestLabel()

@property (nonatomic, strong) UIImageView *labelImageView;

@end

@implementation MXBestLabel
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _labelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, frame.size.width, frame.size.height+10)];
        _labelImageView.contentMode = UIViewContentModeScaleAspectFit;
        _labelImageView.clipsToBounds = YES;
        [self addSubview:_labelImageView];
        
        self.userInteractionEnabled = YES;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        _font = [UIFont systemFontOfSize:17];
        _textColor = [UIColor blackColor];
        _textAlignment = NSTextAlignmentLeft;
    }
    return self;
}


//use coretext draw text as image
- (void)setText:(NSString *)text {
    if (text == nil || text.length == 0) {
        self.labelImageView = nil;
        return;
    }
    if ([text isEqualToString:self.text]) {
        return;
    }
    //async draw
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *temp = text;
        weakself.text = text;
        CGSize size = self.frame.size;
        size.height += 10;
        UIGraphicsBeginImageContextWithOptions(size, ![self.backgroundColor isEqual:[UIColor clearColor]], 0);
        CGContextRef ref = UIGraphicsGetCurrentContext();
        if (ref == nil) {
            return;
        }
        if (![self.backgroundColor isEqual:[UIColor clearColor]]) {
            [self.backgroundColor set];
            CGContextFillRect(ref, CGRectMake(0, 0, size.width, size.height));
        }
        //CGContextSetTextMatrix调整坐标系，防止文字倒立
        CGContextSetTextMatrix(ref, CGAffineTransformIdentity);
        //
        CGContextTranslateCTM(ref, 0, size.height);
    });
}



- (void)clear {
    
}



@end
