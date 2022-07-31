//
//  STRippleAnimationView.h
//  STLivenessController
//
//  Created by huoqiuliang on 16/12/7.
//  Copyright © 2016年 sensetime. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, STAnimationType) { STAnimationTypeWithBackground, STAnimationTypeWithoutBackground };

@interface STRippleAnimationView : UIView

/**
 设置扩散倍数。默认1.423倍
 */
@property (nonatomic, assign) CGFloat multiple;

- (instancetype)initWithFrame:(CGRect)frame animationType:(STAnimationType)animationType;

@end
