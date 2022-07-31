//
//  STLivenessView.m
//  FinanceDemo
//
//  Created by zhanghenan on 2018/7/26.
//  Copyright © 2018年 sensetime. All rights reserved.
//

#import "STLivenessView.h"
#import "STRippleAnimationView.h"
#import "STLivenessCommon.h"
#import "UIView+EX.h"

#define PHONE_BUTTON_IMAGEVIEW_TO_LETF (IS_IPHONE ? 69 : 103 * 2)
//摄像命令与摄像区域间隔
#define PHONE_BUTTON_IMAGEVIEW_TO_BOTTOM (IS_IPHONE ? 265 : 121 * 2)
#define PHONE_BUTTON_IMAGEVIEW_WIDTH 36
//#define PHONE_BUTTON_IMAGEVIEW_TOP kSTScreenHeight - PHONE_BUTTON_IMAGEVIEW_TO_BOTTOM - PHONE_BUTTON_IMAGEVIEW_WIDTH
//摄像区域间隔
#define CICLE_TO_LEFT (IS_IPHONE ? 50 : 70 * 2)
#define CICLE_TO_WH (kSTScreenWidth - CICLE_TO_LEFT * 2)
#define PHONE_BUTTON_IMAGEVIEW_TOP CICLE_TO_WH + 80

#define PHONE_RIPPLE_VIEW_WIDTH PHONE_BUTTON_IMAGEVIEW_WIDTH

#define PHONE_4_BUTTON_IMAGEVIEW_SPACE \
    (kSTScreenWidth - PHONE_BUTTON_IMAGEVIEW_TO_LETF * 2 - PHONE_BUTTON_IMAGEVIEW_WIDTH * 4) / 3
#define PHONE_3_BUTTON_IMAGEVIEW_SPACE \
    (kSTScreenWidth - PHONE_BUTTON_IMAGEVIEW_TO_LETF * 2 - PHONE_BUTTON_IMAGEVIEW_WIDTH * 3) / 2
#define PHONE_2_BUTTON_IMAGEVIEW_SPACE \
    kSTScreenWidth - PHONE_BUTTON_IMAGEVIEW_TO_LETF * 2 - PHONE_BUTTON_IMAGEVIEW_WIDTH * 2

#define PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM 13
#define PHONE_LABEL_HEIGH 15
#define PHONE_LABEL_WIDTH 88

#define LABEL_COLOR 0xcc9233
#define LABEL_FONT 15

#define LINE_COLOR 0xc7c7c7
#define LINE_SUCCESS_COLOR 0xcb9133

//NSInteger const STLivenessLabelFrontSize = 15;
NSInteger const STLivenessLabelFrontSize = 17;
@interface STLivenessView ()
@property (nonatomic, strong) UIImageView *fisrtMotionImageView;
@property (nonatomic, strong) UIImageView *secondMotionImageView;
@property (nonatomic, strong) UIImageView *thirdMotionImageView;
@property (nonatomic, strong) UIImageView *forthMotionImageView;

@property (nonatomic, strong) STRippleAnimationView *rippleAnimationView;

@property (nonatomic, strong) UILabel *fisrtMotionLabel;
@property (nonatomic, strong) UILabel *sencondMotionLabel;
@property (nonatomic, strong) UILabel *thirdMotionLabel;
@property (nonatomic, strong) UILabel *forthMotionLabel;
@property (nonatomic, strong) NSMutableArray *motionArray;
@property (nonatomic, strong) NSArray *allArray;

@property (nonatomic, strong) NSMutableArray *motionStringArray;

@property (nonatomic, strong) CALayer *firstLineLayer;
@property (nonatomic, strong) CALayer *secondLineLayer;
@property (nonatomic, strong) CALayer *thirdLineLayer;

@property (nonatomic, assign) NSInteger firstMotionInteger;
@property (nonatomic, assign) NSInteger secondMotionInteger;
@property (nonatomic, assign) NSInteger thirdMotionInteger;
@property (nonatomic, assign) NSInteger forthMotionInteger;

@property (nonatomic, strong) NSString *firstMotionString;
@property (nonatomic, strong) NSString *secondMotionString;
@property (nonatomic, strong) NSString *thirdMotionString;
@property (nonatomic, strong) NSString *forthMotionString;
@property (nonatomic, assign) NSInteger currentMotion;

@end

@implementation STLivenessView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }

    self.allArray = @[@"眨眼", @"点头", @"张嘴", @"摇头"];
    self.motionArray = [[NSMutableArray alloc] init];
    self.currentMotion = 0;
    self.motionStringArray = [[NSMutableArray alloc] init];
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    self.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _maskCoverView = [[LivenessMaskView alloc] initWithFrame:CGRectMake(0, -2, self.bounds.size.width, self.bounds.size.height)];

    _maskCoverView.lineColor = [UIColor clearColor];
    [self addSubview:_maskCoverView];
    _hintLabel = [[UILabel alloc] init];
    [_hintLabel setBackgroundColor:[UIColor clearColor]];
//    [_hintLabel setTextColor:kSTColorWithRGB(0xc7c7c7)];
    [_hintLabel setTextColor:[UIColor blackColor]];
    [_hintLabel setFont:[UIFont boldSystemFontOfSize:STLivenessLabelFrontSize]];
    if (IS_IPHONE) {
        [_hintLabel setFrame:CGRectMake(0, PHONE_BUTTON_IMAGEVIEW_TOP - 50, kSTScreenWidth, 20)];
    } else {
        [_hintLabel setFrame:CGRectMake(0, PHONE_BUTTON_IMAGEVIEW_TOP - 50, kSTScreenWidth, 20)];
    }
    [_hintLabel setTextAlignment:NSTextAlignmentCenter];
    [_hintLabel setNumberOfLines:0];

    [self addSubview:_hintLabel];
    
    
    _resultLabel = [[UILabel alloc] init];
    [_resultLabel setBackgroundColor:[UIColor clearColor]];
    [_resultLabel setTextColor:[UIColor darkGrayColor]];
    [_resultLabel setFont:[UIFont systemFontOfSize:15]];
    if (IS_IPHONE) {
        [_resultLabel setFrame:CGRectMake(0, PHONE_BUTTON_IMAGEVIEW_TOP - 50 + 30, kSTScreenWidth, 20)];
    } else {
        [_resultLabel setFrame:CGRectMake(0, PHONE_BUTTON_IMAGEVIEW_TOP - 50 + 30, kSTScreenWidth, 20)];
    }
    [_resultLabel setTextAlignment:NSTextAlignmentCenter];
    [_resultLabel setNumberOfLines:0];

    [self addSubview:_resultLabel];
    return self;
}
- (void)setCircleRect:(CGRect)circleRect {
    _maskCoverView.circleRect = circleRect;
}
- (void)layoutSubviews {
    [self addLayer];

    [self initBottomView];
    [self setBottomView];
}

- (void)setDetectionArr:(NSMutableArray *)detectionArr {
    _detectionArr = detectionArr;
    for (int i = 0; i < detectionArr.count; i++) {
        NSNumber *index = detectionArr[i];
        [self.motionArray addObject:self.allArray[[index integerValue]]];
    }
}

- (void)initBottomView {
    self.fisrtMotionImageView = [[UIImageView alloc] init];
    self.secondMotionImageView = [[UIImageView alloc] init];
    self.thirdMotionImageView = [[UIImageView alloc] init];
    self.forthMotionImageView = [[UIImageView alloc] init];
    self.rippleAnimationView =
        [[STRippleAnimationView alloc] initWithFrame:CGRectMake(0, 0, PHONE_RIPPLE_VIEW_WIDTH, PHONE_RIPPLE_VIEW_WIDTH)
                                       animationType:STAnimationTypeWithBackground];
    self.rippleAnimationView.hidden = YES;
    self.fisrtMotionLabel = [[UILabel alloc] init];
    self.sencondMotionLabel = [[UILabel alloc] init];
    self.thirdMotionLabel = [[UILabel alloc] init];
    self.forthMotionLabel = [[UILabel alloc] init];

    self.fisrtMotionImageView.image = [self imageWithFullFileName:@"st_liveness_waitting"];
    self.secondMotionImageView.image = [self imageWithFullFileName:@"st_liveness_waitting"];
    self.thirdMotionImageView.image = [self imageWithFullFileName:@"st_liveness_waitting"];
    self.forthMotionImageView.image = [self imageWithFullFileName:@"st_liveness_waitting"];

    self.fisrtMotionLabel.textColor = kSTColorWithRGB(LABEL_COLOR);
    self.fisrtMotionLabel.font = [UIFont systemFontOfSize:LABEL_FONT];
    self.fisrtMotionLabel.textAlignment = NSTextAlignmentCenter;

    self.sencondMotionLabel.textColor = kSTColorWithRGB(LABEL_COLOR);
    self.sencondMotionLabel.font = [UIFont systemFontOfSize:LABEL_FONT];
    self.sencondMotionLabel.textAlignment = NSTextAlignmentCenter;

    self.thirdMotionLabel.textColor = kSTColorWithRGB(LABEL_COLOR);
    self.thirdMotionLabel.font = [UIFont systemFontOfSize:LABEL_FONT];
    self.thirdMotionLabel.textAlignment = NSTextAlignmentCenter;

    self.forthMotionLabel.textColor = kSTColorWithRGB(LABEL_COLOR);
    self.forthMotionLabel.font = [UIFont systemFontOfSize:LABEL_FONT];
    self.forthMotionLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:self.rippleAnimationView];

    [self addSubview:self.fisrtMotionImageView];
    [self addSubview:self.secondMotionImageView];
    [self addSubview:self.thirdMotionImageView];
    [self addSubview:self.forthMotionImageView];

    [self addSubview:self.fisrtMotionLabel];
    [self addSubview:self.sencondMotionLabel];
    [self addSubview:self.thirdMotionLabel];
    [self addSubview:self.forthMotionLabel];
    
    self.rippleAnimationView.hidden = YES;
    
    self.fisrtMotionImageView.hidden = YES;
    self.secondMotionImageView.hidden = YES;
    self.thirdMotionImageView.hidden = YES;
    self.forthMotionImageView.hidden = YES;
    
    self.fisrtMotionLabel.hidden = YES;
    self.sencondMotionLabel.hidden = YES;
    self.thirdMotionLabel.hidden = YES;
    self.forthMotionLabel.hidden = YES;
}

- (void)addLayer {
    self.firstLineLayer = [CALayer layer];
    self.firstLineLayer.backgroundColor = kSTColorWithRGB(LINE_COLOR).CGColor;

    self.secondLineLayer = [CALayer layer];
    self.secondLineLayer.backgroundColor = kSTColorWithRGB(LINE_COLOR).CGColor;

    self.thirdLineLayer = [CALayer layer];
    self.thirdLineLayer.backgroundColor = kSTColorWithRGB(LINE_COLOR).CGColor;

    [self.layer addSublayer:self.firstLineLayer];
    [self.layer addSublayer:self.secondLineLayer];
    [self.layer addSublayer:self.thirdLineLayer];
    
    self.firstLineLayer.hidden = YES;
    self.secondLineLayer.hidden = YES;
    self.thirdLineLayer.hidden = YES;
}

- (void)setBottomView {
    switch (self.motionArray.count) {
        case 1:
            self.fisrtMotionImageView.frame =
                CGRectMake(0, PHONE_BUTTON_IMAGEVIEW_TOP, PHONE_BUTTON_IMAGEVIEW_WIDTH, PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.fisrtMotionImageView.center = CGPointMake(kSTScreenWidth / 2, self.fisrtMotionImageView.center.y);
            self.fisrtMotionLabel.frame =
                CGRectMake(0,
                           self.fisrtMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.fisrtMotionLabel.center =
                CGPointMake(self.fisrtMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.fisrtMotionLabel.text = self.motionArray[0];
            break;
        case 2:
            self.fisrtMotionImageView.frame = CGRectMake(PHONE_BUTTON_IMAGEVIEW_TO_LETF,
                                                         PHONE_BUTTON_IMAGEVIEW_TOP,
                                                         PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                         PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.fisrtMotionLabel.frame =
                CGRectMake(0,
                           self.fisrtMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.fisrtMotionLabel.center =
                CGPointMake(self.fisrtMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.fisrtMotionLabel.text = self.motionArray[0];

            self.secondMotionImageView.frame =
                CGRectMake(kSTScreenWidth - PHONE_BUTTON_IMAGEVIEW_TO_LETF - PHONE_BUTTON_IMAGEVIEW_WIDTH,
                           PHONE_BUTTON_IMAGEVIEW_TOP,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.sencondMotionLabel.frame =
                CGRectMake(0,
                           self.fisrtMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.sencondMotionLabel.center =
                CGPointMake(self.secondMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.sencondMotionLabel.text = self.motionArray[1];

            self.firstLineLayer.frame = CGRectMake(self.fisrtMotionImageView.center.x,
                                                   self.fisrtMotionImageView.center.y,
                                                   PHONE_2_BUTTON_IMAGEVIEW_SPACE + PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                   1);
            break;
        case 3:
            self.fisrtMotionImageView.frame = CGRectMake(PHONE_BUTTON_IMAGEVIEW_TO_LETF,
                                                         PHONE_BUTTON_IMAGEVIEW_TOP,
                                                         PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                         PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.fisrtMotionLabel.frame =
                CGRectMake(0,
                           self.fisrtMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.fisrtMotionLabel.center =
                CGPointMake(self.fisrtMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.fisrtMotionLabel.text = self.motionArray[0];

            self.secondMotionImageView.frame =
                CGRectMake(0, PHONE_BUTTON_IMAGEVIEW_TOP, PHONE_BUTTON_IMAGEVIEW_WIDTH, PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.secondMotionImageView.center = CGPointMake(kSTScreenWidth / 2, self.fisrtMotionImageView.center.y);
            self.sencondMotionLabel.frame =
                CGRectMake(0,
                           self.fisrtMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.sencondMotionLabel.center =
                CGPointMake(self.secondMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.sencondMotionLabel.text = self.motionArray[1];

            self.thirdMotionImageView.frame =
                CGRectMake(kSTScreenWidth - PHONE_BUTTON_IMAGEVIEW_TO_LETF - PHONE_BUTTON_IMAGEVIEW_WIDTH,
                           PHONE_BUTTON_IMAGEVIEW_TOP,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.thirdMotionLabel.frame =
                CGRectMake(0,
                           self.fisrtMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.thirdMotionLabel.center =
                CGPointMake(self.thirdMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.thirdMotionLabel.text = self.motionArray[2];

            self.firstLineLayer.frame = CGRectMake(self.fisrtMotionImageView.center.x,
                                                   self.fisrtMotionImageView.center.y,
                                                   PHONE_3_BUTTON_IMAGEVIEW_SPACE + PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                   1);
            self.secondLineLayer.frame = CGRectMake(self.secondMotionImageView.center.x,
                                                    self.secondMotionImageView.center.y,
                                                    PHONE_3_BUTTON_IMAGEVIEW_SPACE + PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                    1);
            break;
        case 4:
            self.fisrtMotionImageView.frame = CGRectMake(PHONE_BUTTON_IMAGEVIEW_TO_LETF,
                                                         PHONE_BUTTON_IMAGEVIEW_TOP,
                                                         PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                         PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.fisrtMotionLabel.frame =
                CGRectMake(0,
                           self.fisrtMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.fisrtMotionLabel.center =
                CGPointMake(self.fisrtMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.fisrtMotionLabel.text = self.motionArray[0];

            self.secondMotionImageView.frame =
                CGRectMake(self.fisrtMotionImageView.stRight + PHONE_4_BUTTON_IMAGEVIEW_SPACE,
                           self.fisrtMotionImageView.stOrigin.y,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.sencondMotionLabel.frame =
                CGRectMake(0,
                           self.secondMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.sencondMotionLabel.center =
                CGPointMake(self.secondMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.sencondMotionLabel.text = self.motionArray[1];

            self.thirdMotionImageView.frame =
                CGRectMake(self.secondMotionImageView.stRight + PHONE_4_BUTTON_IMAGEVIEW_SPACE,
                           self.fisrtMotionImageView.stOrigin.y,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.thirdMotionLabel.frame =
                CGRectMake(0,
                           self.thirdMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.thirdMotionLabel.center =
                CGPointMake(self.thirdMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.thirdMotionLabel.text = self.motionArray[2];

            self.forthMotionImageView.frame =
                CGRectMake(kSTScreenWidth - PHONE_BUTTON_IMAGEVIEW_TO_LETF - PHONE_BUTTON_IMAGEVIEW_WIDTH,
                           PHONE_BUTTON_IMAGEVIEW_TOP,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH,
                           PHONE_BUTTON_IMAGEVIEW_WIDTH);
            self.forthMotionLabel.frame =
                CGRectMake(0,
                           self.forthMotionImageView.stBottom + PHONE_LABEL_TO_IMGAGEVIEW_BOTTOM,
                           PHONE_LABEL_WIDTH,
                           PHONE_LABEL_HEIGH);
            self.forthMotionLabel.center =
                CGPointMake(self.forthMotionImageView.center.x, self.fisrtMotionLabel.center.y);
            self.forthMotionLabel.text = self.motionArray[3];

            self.firstLineLayer.frame = CGRectMake(self.fisrtMotionImageView.center.x,
                                                   self.fisrtMotionImageView.center.y,
                                                   PHONE_4_BUTTON_IMAGEVIEW_SPACE + PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                   1);
            self.secondLineLayer.frame = CGRectMake(self.secondMotionImageView.center.x,
                                                    self.secondMotionImageView.center.y,
                                                    PHONE_4_BUTTON_IMAGEVIEW_SPACE + PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                    1);
            self.thirdLineLayer.frame = CGRectMake(self.thirdMotionImageView.center.x,
                                                   self.thirdMotionImageView.center.y,
                                                   PHONE_4_BUTTON_IMAGEVIEW_SPACE + PHONE_BUTTON_IMAGEVIEW_WIDTH,
                                                   1);
            break;
        default:
            break;
    }
}

- (CGFloat)modifyYRatio {
    CGFloat videoRatio = 720.0 / 1280.0;
    CGFloat uiRatio = CGRectGetWidth(self.bounds) / CGRectGetHeight(self.bounds);
    return uiRatio / videoRatio;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    self.maskCoverView.lineColor = lineColor;
    [self.maskCoverView setNeedsDisplay];
}

- (void)startAnimation {
    self.fisrtMotionImageView.image = [self imageWithFullFileName:@"st_liveness_stepping"];
    self.rippleAnimationView.hidden = NO;
    self.rippleAnimationView.center = self.fisrtMotionImageView.center;
}

- (void)nextMotion {
    switch (self.currentMotion) {
        case 1:
            self.fisrtMotionImageView.image = [self imageWithFullFileName:@"st_liveness_done"];
            self.secondMotionImageView.image = [self imageWithFullFileName:@"st_liveness_stepping"];
            self.rippleAnimationView.center = self.secondMotionImageView.center;
            self.firstLineLayer.backgroundColor = kSTColorWithRGB(LINE_SUCCESS_COLOR).CGColor;
            break;
        case 2:
            self.secondMotionImageView.image = [self imageWithFullFileName:@"st_liveness_done"];
            self.thirdMotionImageView.image = [self imageWithFullFileName:@"st_liveness_stepping"];
            self.rippleAnimationView.center = self.thirdMotionImageView.center;
            self.secondLineLayer.backgroundColor = kSTColorWithRGB(LINE_SUCCESS_COLOR).CGColor;

            break;
        case 3:
            self.thirdMotionImageView.image = [self imageWithFullFileName:@"st_liveness_done"];
            self.forthMotionImageView.image = [self imageWithFullFileName:@"st_liveness_stepping"];
            self.rippleAnimationView.center = self.forthMotionImageView.center;
            self.thirdLineLayer.backgroundColor = kSTColorWithRGB(LINE_SUCCESS_COLOR).CGColor;

            break;
        case 4:
            self.forthMotionImageView.image = [self imageWithFullFileName:@"st_liveness_done"];
            ;
            break;
        default:
            break;
    }
    self.currentMotion++;
}

- (UIImage *)imageWithFullFileName:(NSString *)fileNameStr {
    NSBundle *motionBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePathStr = [NSString pathWithComponents:@[
        [motionBundle pathForResource:@"st_liveness_resource" ofType:@"bundle"],
        @"images",
        fileNameStr
    ]];
    return [UIImage imageWithContentsOfFile:filePathStr];
}

@end

@interface LivenessMaskView ()

@end

@implementation LivenessMaskView {
    CGContextRef context;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _lineColor = kSTColorWithRGB(0x777777);
        _maskAlpha = 1.0;
        _maskColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:_maskAlpha];
//        _maskColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:_maskAlpha];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    context = UIGraphicsGetCurrentContext();
    CGFloat redColor = 0;
    CGFloat blueColor = 0;
    CGFloat greenColor = 0;
    [self.maskColor getRed:&redColor green:&greenColor blue:&blueColor alpha:nil];
    UIColor *maskColor = [UIColor colorWithRed:redColor green:greenColor blue:blueColor alpha:self.maskAlpha];
    [maskColor setFill];
    CGContextFillRect(context, self.bounds);

    [self.lineColor set];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.circleRect.origin.x,
                                                                                 self.circleRect.origin.y,
                                                                                 self.circleRect.size.width,
                                                                                 self.circleRect.size.height)];
    [circlePath fillWithBlendMode:kCGBlendModeClear alpha:1.0];
    circlePath.lineWidth = 2;
    [circlePath stroke];
}

@end
