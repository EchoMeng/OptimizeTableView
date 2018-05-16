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

#define RegularHighLightTypeURL @"url"
#define RegularHighLightTypeAccount @"account"
#define RegularHighLightTypeTopic @"topic"
#define RegularHighLightTypeEmoji @"emoji"
#define URLRegular @"(http|https)://(t.cn/|weibo.com/)+(([a-zA-Z0-9/])*)"
#define EmojiRegular @"(\\[\\w+\\])"
#define AccountRegualr @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"
#define TopicRegular @"#[^#]+#"


@interface MXBestLabel()

@property (nonatomic, strong) UIImageView *labelImageView;

@property (nonatomic, strong) UIImageView *highlightLabelImageView;

@property (nonatomic, assign) NSInteger drawFlag;

@property (nonatomic, strong) NSMutableDictionary *highlightColors;

@property (nonatomic, strong) NSMutableDictionary *framesDic;

@property (nonatomic, assign) NSRange currentRange;

@property (nonatomic, assign) BOOL highlighting;

@end

@implementation MXBestLabel

//由于直接采用CoreText绘制label会导致文字的部分截断，因此需要调整frame，高度+10，origin.y-5
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _drawFlag = arc4random();
        _framesDic = [[NSMutableDictionary alloc] init];
        _highlightColors = [[NSMutableDictionary alloc] initWithObjectsAndKeys:kColorURL,RegularHighLightTypeURL,kColorEmoji,RegularHighLightTypeEmoji, kColorTopic, RegularHighLightTypeTopic, kColorAccount, RegularHighLightTypeAccount, nil];
        _labelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, frame.size.width, frame.size.height+10)];
        _labelImageView.contentMode = UIViewContentModeScaleAspectFit;
        _labelImageView.clipsToBounds = YES;
        [self addSubview:_labelImageView];
        
        _highlightLabelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, frame.size.width, frame.size.height + 10)];
        _highlightLabelImageView.contentMode = UIViewContentModeScaleAspectFit;
        _highlightLabelImageView.clipsToBounds = YES;
        [self addSubview:_highlightLabelImageView];
        
        self.userInteractionEnabled = YES;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        _font = [UIFont systemFontOfSize:17];
        _textColor = [UIColor blackColor];
        _textAlignment = NSTextAlignmentLeft;
        _lineSpace = LineSpace;
    }
    return self;
}

//fix coreText frame
- (void)setFrame:(CGRect)frame {
    if (!CGSizeEqualToSize(self.labelImageView.frame.size, frame.size)) {
        self.labelImageView.image = nil;
        self.highlightLabelImageView.image = nil;
    }
    self.labelImageView.frame = CGRectMake(0, -5, frame.size.width, frame.size.height+10);
    self.highlightLabelImageView.frame = CGRectMake(0, -5, frame.size.width, frame.size.height);
    [super setFrame:frame];
}

//高亮处理
- (NSMutableAttributedString *)highlightText:(NSMutableAttributedString *)attributedString {
    NSString *string = attributedString.string;
    NSRange range = NSMakeRange(0, [string length]);
    NSDictionary *defination = @{
                                 RegularHighLightTypeAccount: AccountRegualr,
                                 RegularHighLightTypeTopic: TopicRegular,
                                 RegularHighLightTypeEmoji: EmojiRegular,
                                 RegularHighLightTypeURL: URLRegular
                                 };
    for (NSString *key in defination) {
        NSString *expression = [defination objectForKey:key];
        NSArray *matches = [[NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:string options:0 range:range];
        for (NSTextCheckingResult *match in matches) {
//            UIColor *textColor = nil;
//            if (!_highlightColors || !(textColor = ([self.highlightColors objectForKey:key]))) {
//                textColor = self.textColor;
//            }
            __block UIImage *labelImage;
            dispatch_async(dispatch_get_main_queue(), ^{
                labelImage = self.labelImageView.image;
            });
            if (labelImage != nil && self.currentRange.location != -1 && self.currentRange.location >= match.range.location && self.currentRange.length + self.currentRange.location <= match.range.length + match.range.location) {
                [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor purpleColor] range:match.range];
                double delayInSeconds = 2;
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds);
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    [self backToNormal];
                });
            } else {
                UIColor *highlightColor = self.highlightColors[key];
                [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)highlightColor.CGColor range:match.range];
            }
        }
    }
    return attributedString;
}

- (void)backToNormal {
    if (!_highlighting) {
        return;
    }
    _highlighting = NO;
    _currentRange = NSMakeRange(-1, -1);
    _highlightLabelImageView.image = nil;
}

- (void)highlightWords {
    self.highlighting = YES;
    [self setText:_text];
}

//use coretext draw text as image
//使用core text就是先有一个要显示的string，然后定义这个string每个部分的样式－>attributedString －> 生成 CTFramesetter -> 得到CTFrame -> 绘制（CTFrameDraw） 其中可以更详细的设置换行方式，对齐方式，绘制区域的大小等。
- (void)setText:(NSString *)text {
    if (text == nil || text.length <= 0) {
        self.labelImageView.image = nil;
        self.highlightLabelImageView.image = nil;
        return;
    }
    if ([text isEqualToString:self.text]) {
        if (!_highlighting || _currentRange.location == -1) {
            return;
        }
    }
    if (self.highlighting && self.labelImageView.image == nil) {
        return;
    }
    if (!_highlighting) {
        _currentRange = NSMakeRange(-1, -1);
    }
    NSInteger flag = self.drawFlag;
    BOOL isHighlighting = self.highlighting;
    //async draw
    __weak typeof(self) weakself = self;
    _text = text;
    UIColor *bgColor = [self.backgroundColor copy];
    __block CGSize size = self.frame.size;
    size.height += 10;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *temp = text;
        UIGraphicsBeginImageContextWithOptions(size, ![bgColor isEqual:[UIColor clearColor]], 0);
        //打开上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) {
            return;
        }
        
        //CGContextSetTextMatrix调整坐标系，防止文字倒立。当前对文本执行变换的变换矩阵
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        //绘制需要从坐标左下角为原点，因此需要坐标轴翻转
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        //默认颜色
        UIColor *textColor = self.textColor;
        //设置行高，字体，颜色，和对齐方式
        
        //字体
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
        //line break mode
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        //对齐方式
        CTTextAlignment textAlignment = NSTextAlignmentToCTTextAlignment(self.textAlignment);
        
        CGFloat maxLineHeight = MaxLineHeight;
        CGFloat minLineHeight = MinLineHeight;
        CGFloat lineSpace = self.lineSpace;
        
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
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font, (NSString *)kCTFontAttributeName, (__bridge id)textColor.CGColor, (id)kCTForegroundColorAttributeName, (__bridge id)style, (id)kCTParagraphStyleAttributeName, nil];
        
        //创建CFAttributedStringRef
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
        CFAttributedStringRef attributeString = (__bridge CFAttributedStringRef)[self highlightText:attributeStr];
        //draw
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributeString);
        CGRect rect = CGRectMake(0, 5, size.width, size.height-5);
        //background color
        if (![bgColor isEqual:[UIColor clearColor]]) {
            [self.backgroundColor set];
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        }
        
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
                [[attributeStr mutableString] setString:@""];
                if (weakself.drawFlag == flag) {
                    if (isHighlighting) {
                        weakself.highlightLabelImageView.image = nil;
                        if (weakself.highlightLabelImageView.width != screenShootImage.size.width) {
                            weakself.highlightLabelImageView.width = screenShootImage.size.width;
                        }
                        if (weakself.highlightLabelImageView.height != screenShootImage.size.height) {
                            weakself.highlightLabelImageView.height = screenShootImage.size.height;
                        }
                        self.highlightLabelImageView.image = screenShootImage;
                    } else {
                        if ([temp isEqualToString:text]) {
                            if (weakself.labelImageView.width != screenShootImage.size.width) {
                                weakself.labelImageView.width = screenShootImage.size.width;
                            }
                            if (weakself.labelImageView.height != screenShootImage.size.height) {
                                weakself.labelImageView.height = screenShootImage.size.height;
                            }
                            weakself.labelImageView.image = nil;
                            weakself.highlightLabelImageView.image = nil;
                            weakself.labelImageView.image = screenShootImage;
                        }
                    }
                }
            });
        }
        CFRelease(font);
        CFRelease(framesetter);
        CFRelease(style);
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
        if (!self.highlighting && self.superview != nil) {
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            for (int j = 0;  j < CFArrayGetCount(runs); j++) {
                CGFloat runAscent;
                CGFloat runDescent;
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes(run);
                if (!CGColorEqualToColor((__bridge CGColorRef)([attributes valueForKey:@"CTForegroundColor"]), self.textColor.CGColor) && self.framesDic != nil) {
                    CFRange range = CTRunGetStringRange(run);
                    CGRect runRect;
                    runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                    float offset = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                    float height = runAscent;
                    __block CGFloat selfFrameHeight;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        selfFrameHeight = self.frame.size.height;
                    });
                    runRect = CGRectMake(lineOrigin.x+offset, (self.height+5)-y-height+runDescent/2, runRect.size.width, height);
                    NSRange nRange = NSMakeRange(range.location, range.length);
                    [self.framesDic setValue:[NSValue valueWithCGRect:runRect] forKey:NSStringFromRange(nRange)];
                }
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
}

- (void)clear {
    _drawFlag = arc4random();
    _text = @"";
    _labelImageView.image = nil;
}

- (void)dealloc {
    NSLog(@"dealloc:%@", self);
}

//处理文本点击事件
//实际上是整个label响应点击事件，判断点击位置是否在高亮文本相应位置上
//需要高亮时，highlightImage会显示，目前是叠加在原图上层
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    for (NSString *key in self.framesDic.allKeys) {
        CGRect frame = [[self.framesDic valueForKey:key] CGRectValue];
        if (CGRectContainsPoint(frame, location)) {
            NSRange range = NSRangeFromString(key);
            range = NSMakeRange(range.location, range.length - 1);
            _currentRange = range;
            [self highlightWords];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.highlighting) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [self backToNormal];
        });
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
}

- (BOOL)touchPoint:(CGPoint)point {
    return NO;
}

@end
