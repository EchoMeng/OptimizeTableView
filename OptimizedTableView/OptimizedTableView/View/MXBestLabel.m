//
//  MXBestLabel.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXBestLabel.h"
#import <CoreText/CoreText.h>
#import "UIView+Additions.h"

@interface MXBestLabel()

@property (nonatomic, strong) UIImageView *labelImageView;

@property (nonatomic, assign) NSInteger drawFlag;

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
        _lineSpace = 5;
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
    NSInteger flag = self.drawFlag;
    //async draw
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *temp = text;
        weakself.text = text;
        CGSize size = self.frame.size;
        size.height += 10;
        UIGraphicsBeginImageContextWithOptions(size, ![self.backgroundColor isEqual:[UIColor clearColor]], 0);
        //打开上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == nil) {
            return;
        }
        if (![self.backgroundColor isEqual:[UIColor clearColor]]) {
            [self.backgroundColor set];
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        }
        //CGContextSetTextMatrix调整坐标系，防止文字倒立。当前对文本执行变换的变换矩阵
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        //绘制需要从坐标左下角为原点，因此需要坐标轴翻转
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        //默认颜色
        UIColor *textColor = self.textColor;
        //设置行高，字体，颜色，和对齐方式
        CGFloat minLineHeight = self.font.pointSize;
        CGFloat maxLineHeight = minLineHeight;
        CGFloat lineSpace = self.lineSpace;
        //字体
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
        //line break mode
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        //对齐方式
        CTTextAlignment textAlignment = NSTextAlignmentToCTTextAlignment(self.textAlignment);
        
        //将上述设置应用到字体style中 kCTParagraphStyleAttributeName
        CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]) {
            {kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment},
            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakMode), &lineBreakMode},
            {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxLineHeight), &maxLineHeight},
            {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(minLineHeight), &minLineHeight},
            {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(lineSpace), &lineSpace},
            {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(lineSpace), &lineSpace}
        }, 6);
        
        //attribute字典里包含文字字体、颜色、style等信息
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font, (NSString *)kCTFontAttributeName, textColor.CGColor, kCTForegroundColorAttributeName, style, kCTParagraphStyleAttributeName, nil];
        //创建CFAttributedStringRef，没有模仿例子使用高亮
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
        CFAttributedStringRef attributeString = (__bridge CFAttributedStringRef)attributeStr;
        //draw
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributeString);
        CGRect rect = CGRectMake(0, 5, size.width, size.height - 5);
        
        if ([temp isEqualToString:text]) {
            [self drawFrameSetter:framesetter attributeString:attributeStr textRange:CFRangeMake(0, text.length) inRect:rect context:context];
            //这里再次调整了变换矩阵
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextTranslateCTM(context, 0, size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            //截屏
            UIImage *screenShootImage = UIGraphicsGetImageFromCurrentImageContext();
            // 关闭上下文
            UIGraphicsEndImageContext();
            //上述绘制完成之后，回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(font);
                CFRelease(framesetter);
                [[attributeStr mutableString] setString:@""];
                
                if (weakself.drawFlag == flag) {
                    if ([temp isEqualToString:text]) {
                        if (weakself.labelImageView.width != screenShootImage.size.width) {
                            weakself.labelImageView.width = screenShootImage.size.width;
                        }
                        if (weakself.labelImageView.height != screenShootImage.size.height) {
                            weakself.labelImageView.height = screenShootImage.size.height;
                        }
                        weakself.labelImageView.image = nil;
                        weakself.labelImageView.image = screenShootImage;
                    }
                }
            });
        }
    });
}

- (void)drawFrameSetter:(CTFramesetterRef)frameSetter attributeString:(NSAttributedString *)attributeString textRange:(CFRange)textRange inRect:(CGRect)rect context:(CGContextRef)context {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, textRange, path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger linesCount = CFArrayGetCount(lines);//行数
    
    BOOL truncateLastLine = NO;//截断最后一行tailMode
    CGPoint lineOrigins[linesCount];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, linesCount), lineOrigins);
    for (CFIndex i = 0; i < linesCount; i++) {
        CGPoint lineOrigin = lineOrigins[i];
        lineOrigin = CGPointMake(ceil(lineOrigin.x), ceil(lineOrigin.y));//ceil向上取整函数
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGFloat descent = 0.0;
        CGFloat ascent = 0.0;
        CGFloat leading;
        //Calculates the typographic（排版） bounds for a line.
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CGFloat flushFactor = NSTextAlignmentLeft;
        CGFloat penOffset;
        CGFloat y;
        if (i == linesCount - 1 && truncateLastLine) { //如果是最后一行并且截断最后一行
            CFRange lastLineRange = CTLineGetStringRange(line);
            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                CFIndex truncationAttributePosition = lastLineRange.location;
                NSString *truncationTokenString = @"\u2026";//省略号
                NSDictionary *truncationTokenStringAttributes = [attributeString attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
                NSAttributedString *attributeTokenString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributeTokenString);
                NSMutableAttributedString *truncationString = [[attributeString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                if (lastLineRange.length > 0) {
                    unichar lastCharacter = [[truncationString string] characterAtIndex:(lastLineRange.length - 1)];
                    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                    }
                }
                [truncationString appendAttributedString:attributeTokenString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    truncatedLine = CFRetain(truncationToken);
                }
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(truncatedLine, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender;
                CGContextSetTextPosition(context, penOffset, y);
                CTLineDraw(truncatedLine, context);
                CFRelease(truncatedLine);
                CFRelease(truncationToken);
                CFRelease(truncationLine);
            } else {
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender;
                CGContextSetTextPosition(context, penOffset, y);
                CTLineDraw(line, context);
            }
        } else {
            penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
            y = lineOrigin.y - descent - self.font.descender;
            CGContextSetTextPosition(context, penOffset, y);
            CTLineDraw(line, context);
        }
    }
    
    
    CFRelease(frame);
    CFRelease(path);
}

- (void)clear {
    
}



@end
