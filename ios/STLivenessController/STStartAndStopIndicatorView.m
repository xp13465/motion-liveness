//
//  STSrartAndStopIndicatorView.m
//  STSilentLivenessController
//
//  Created by huoqiuliang on 16/12/7.
//  Copyright © 2016年 sensetime. All rights reserved.
//

#import "STStartAndStopIndicatorView.h"
#import "STLivenessCommon.h"

#define CICLE_TO_WH ([UIScreen mainScreen].bounds.size.width - 50 * 2)

@interface STStartAndStopIndicatorView ()

@property (nonatomic, strong) UIImageView *imageViewAnalyzing;
@property (nonatomic, assign) CGRect viewframe;

@end

@implementation STStartAndStopIndicatorView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _viewframe = frame;
    }
    return self;
}
- (void)indicatorStartAnimate {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        [self addSubview:self.imageViewAnalyzing];
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.f];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
        rotationAnimation.duration = 1.0;
        rotationAnimation.autoreverses = NO;
        rotationAnimation.repeatCount = ULLONG_MAX;
        [self.imageViewAnalyzing.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }];
}

- (UIImageView *)imageViewAnalyzing {
    if (_imageViewAnalyzing) {
        return _imageViewAnalyzing;
    }
    NSBundle *motionBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePathStr = [NSString pathWithComponents:@[
        [motionBundle pathForResource:@"st_liveness_resource" ofType:@"bundle"],
        @"images",
        @"st_liveness_analyzing"
    ]];
    UIImage *image = [UIImage imageWithContentsOfFile:filePathStr];
    _imageViewAnalyzing = [[UIImageView alloc] initWithImage:image];
    _imageViewAnalyzing.frame = CGRectMake(self.viewframe.size.width / 2 - 25, CICLE_TO_WH / 2 - 25, 50, 50);
    return _imageViewAnalyzing;
}

- (void)indicatorStopAnimate {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        [self.imageViewAnalyzing.layer removeAllAnimations];
        [self.imageViewAnalyzing removeFromSuperview];
        [self removeFromSuperview];
    }];
}

@end
