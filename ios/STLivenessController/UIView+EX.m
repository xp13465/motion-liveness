//
//  UIView+EX.m
//  Internal_Tool_Base_iOS
//
//  Created by huoqiuliang on 2019/7/15.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import "UIView+EX.h"

@implementation UIView (EX)

@dynamic stTop;
@dynamic stBottom;
@dynamic stLeft;
@dynamic stRight;

@dynamic stOrigin;

@dynamic stCenter;
@dynamic stCenterX;
@dynamic stCenterY;

@dynamic stWidth;
@dynamic stHeight;

@dynamic stSize;

- (CGFloat)stTop {
    return self.frame.origin.y;
}

- (void)setStTop:(CGFloat)stTop {
    CGRect frame = self.frame;
    frame.origin.y = stTop;
    self.frame = frame;
}

- (CGFloat)stBottom {
    return self.frame.size.height + self.frame.origin.y;
}

- (void)setStBottom:(CGFloat)stBottom {
    CGRect frame = self.frame;
    frame.origin.y = stBottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)stLeft {
    return self.frame.origin.x;
}

- (void)setStLeft:(CGFloat)stLeft {
    CGRect frame = self.frame;
    frame.origin.x = stLeft;
    self.frame = frame;
}

- (CGFloat)stRight {
    return self.frame.size.width + self.frame.origin.x;
}

- (void)setStRight:(CGFloat)stRight {
    CGRect frame = self.frame;
    frame.origin.x = stRight - frame.size.width;
    self.frame = frame;
}

- (CGPoint)stOrigin {
    return self.frame.origin;
}

- (void)setStOrigin:(CGPoint)stOrigin {
    CGRect frame = self.frame;
    frame.origin = stOrigin;
    self.frame = frame;
}

- (CGPoint)stCenter {
    return self.center;
}

- (void)setStCenter:(CGPoint)stCenter {
    CGPoint center = self.center;
    center.x = stCenter.x;
    center.y = stCenter.y;
    self.center = center;
}

- (CGFloat)stCenterX {
    return self.center.x;
}

- (void)setStCenterX:(CGFloat)stCenterX {
    CGPoint center = self.center;
    center.x = stCenterX;
    self.center = center;
}

- (CGFloat)stCenterY {
    return self.center.y;
}

- (void)setStCenterY:(CGFloat)stCenterY {
    CGPoint center = self.center;
    center.y = stCenterY;
    self.center = center;
}

- (CGFloat)stWidth {
    return self.frame.size.width;
}

- (void)setStWidth:(CGFloat)stWidth {
    CGRect frame = self.frame;
    frame.size.width = stWidth;
    self.frame = frame;
}

- (CGFloat)stHeight {
    return self.frame.size.height;
}

- (void)setStHeight:(CGFloat)stHeight {
    CGRect frame = self.frame;
    frame.size.height = stHeight;
    self.frame = frame;
}

- (CGSize)stSize {
    return self.frame.size;
}

- (void)setStSize:(CGSize)stSize {
    CGRect frame = self.frame;
    frame.size = stSize;
    self.frame = frame;
}

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
              borderColor:(UIColor *)borderColor {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:corners
                                                     cornerRadii:radius];

    CAShapeLayer *temp = [CAShapeLayer layer];
    temp.lineWidth = borderWidth;
    temp.fillColor = [UIColor clearColor].CGColor;
    temp.strokeColor = borderColor.CGColor;
    temp.frame = self.bounds;
    temp.path = path.CGPath;
    [self.layer addSublayer:temp];

    CAShapeLayer *mask = [[CAShapeLayer alloc] initWithLayer:temp];
    mask.path = path.CGPath;
    self.layer.mask = mask;
}

/**
 添加视图边线

 @param type 边线的类型
 @param color 边线的颜色
 @param borderWidth 边线的宽度

 @return 添加有边线的图层
 */
- (CALayer *)addBorderWithType:(BorderType)type color:(UIColor *)color width:(CGFloat)borderWidth {
    CALayer *lineLayer = [CALayer layer];
    if (type == BorderTypeAll) {
        [lineLayer addSublayer:[self addLineOriginPoint:CGPointMake(0.0f, 0.0f)
                                                toPoint:CGPointMake(self.frame.size.width, 0.0f)
                                                  color:color
                                            borderWidth:borderWidth]];
        [lineLayer addSublayer:[self addLineOriginPoint:CGPointMake(0.0f, self.frame.size.height)
                                                toPoint:CGPointMake(self.frame.size.width, self.frame.size.height)
                                                  color:color
                                            borderWidth:borderWidth]];

        [lineLayer addSublayer:[self addLineOriginPoint:CGPointMake(0.f, 0.f)
                                                toPoint:CGPointMake(0.0f, self.frame.size.height)
                                                  color:color
                                            borderWidth:borderWidth]];

        [lineLayer addSublayer:[self addLineOriginPoint:CGPointMake(self.frame.size.width, 0.0f)
                                                toPoint:CGPointMake(self.frame.size.width, self.frame.size.height)
                                                  color:color
                                            borderWidth:borderWidth]];

        return lineLayer;
    }

    // top
    if (type & BorderTypeTop) { //! OCLint
        [lineLayer addSublayer:[self addLineOriginPoint:CGPointMake(0.0f, 0.0f)
                                                toPoint:CGPointMake(self.frame.size.width, 0.0f)
                                                  color:color
                                            borderWidth:borderWidth]];
    }

    // bottom
    if (type & BorderTypeBottom) { //! OCLint
        [lineLayer addSublayer:[self addLineOriginPoint:CGPointMake(0.0f, self.frame.size.height)
                                                toPoint:CGPointMake(self.frame.size.width, self.frame.size.height)
                                                  color:color
                                            borderWidth:borderWidth]];
    }

    // left
    if (type & BorderTypeLeft) { //! OCLint
        [lineLayer addSublayer:[self addLineOriginPoint:CGPointMake(0.f, 0.f)
                                                toPoint:CGPointMake(0.0f, self.frame.size.height)
                                                  color:color
                                            borderWidth:borderWidth]];
    }

    // right
    if (type & BorderTypeRight) { //! OCLint
        [lineLayer addSublayer:[self addLineOriginPoint:CGPointMake(self.frame.size.width, 0.0f)
                                                toPoint:CGPointMake(self.frame.size.width, self.frame.size.height)
                                                  color:color
                                            borderWidth:borderWidth]];
    }

    return lineLayer;
}

- (CAShapeLayer *)addLineOriginPoint:(CGPoint)point0
                             toPoint:(CGPoint)point1
                               color:(UIColor *)color
                         borderWidth:(CGFloat)borderWidth {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:point0];
    [bezierPath addLineToPoint:point1];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = borderWidth;
    return shapeLayer;
}

@end
