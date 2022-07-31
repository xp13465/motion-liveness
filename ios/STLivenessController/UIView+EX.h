//
//  UIView+EX.h
//  Internal_Tool_Base_iOS
//
//  Created by huoqiuliang on 2019/7/15.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (EX)

/** 视图原点坐标与屏幕原点坐标在Y轴上的距离*/
@property (assign, nonatomic) CGFloat stTop;

/** 视图底部与屏幕原点坐标在Y轴上的距离*/
@property (assign, nonatomic) CGFloat stBottom;

/** 视图原点坐标与屏幕原点坐标在X轴上的距离*/
@property (assign, nonatomic) CGFloat stLeft;

/** 视图右侧与屏幕原点坐标在X轴上的距离*/
@property (assign, nonatomic) CGFloat stRight;

/** 视图原点坐标*/
@property (assign, nonatomic) CGPoint stOrigin;

/** 视图中心坐标*/
@property (assign, nonatomic) CGPoint stCenter;

/** 视图中心点与屏幕原点坐标在X轴上的距离*/
@property (assign, nonatomic) CGFloat stCenterX;

/** 视图中心点与屏幕原点坐标在Y轴上的距离*/
@property (assign, nonatomic) CGFloat stCenterY;

/** 视图的宽度*/
@property (assign, nonatomic) CGFloat stWidth;

/** 视图的高度*/
@property (assign, nonatomic) CGFloat stHeight;

/** 视图的尺寸*/
@property (assign, nonatomic) CGSize stSize;

/**
 设置部分圆角(绝对布局)

 @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft |
 UIRectCornerBottomRight | UIRectCornerAllCorners
 @param radius 需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 @param borderWidth 圆角边线的宽度
 @param borderColor 圆角边线的颜色
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                   radius:(CGSize)radius
              borderWidth:(CGFloat)borderWidth
              borderColor:(UIColor *)borderColor;

/**
 边线的类型

 - BorderTypeTop: 顶部边线
 - BorderTypeBottom: 底部边线
 - BorderTypeLeft: 左侧边线
 - BorderTypeRight: 右侧边线
 - BorderTypeAll: 所有边线
 */
typedef NS_ENUM(NSUInteger, BorderType) {
    BorderTypeTop = 1 << 0,
    BorderTypeBottom = 1 << 1,
    BorderTypeLeft = 1 << 2,
    BorderTypeRight = 1 << 3,
    BorderTypeAll = ~0UL
};

/**
 添加视图边线

 @param type 边线的类型
 @param color 边线的颜色
 @param borderWidth 边线的宽度

 @return 添加有边线的图层
 */
- (CALayer *)addBorderWithType:(BorderType)type color:(UIColor *)color width:(CGFloat)borderWidth;

@end

NS_ASSUME_NONNULL_END
