//
//  STLivenessView.h
//  FinanceDemo
//
//  Created by zhanghenan on 2018/7/26.
//  Copyright © 2018年 sensetime. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LivenessMaskView;

@interface STLivenessView : UIView

@property (nonatomic) LivenessMaskView *maskCoverView;
@property (nonatomic, assign) CGRect circleRect; //扫描框位置
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) NSMutableArray *detectionArr;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)nextMotion;
- (void)startAnimation;
@end

@interface LivenessMaskView : UIView

@property (nonatomic, assign) CGRect circleRect;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) CGFloat maskAlpha;

@end
