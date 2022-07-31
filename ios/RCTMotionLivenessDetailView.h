//
//  RCTMotionLivenessDetailView.h
//  CMChat
//
//  Created by 顔飞 on 2021/3/8.
//  Copyright © 2021 草莓聊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import "Cml_LivingCheckController.h"
NS_ASSUME_NONNULL_BEGIN


@interface RCTMotionLivenessDetailView : UIView
@property (nonatomic,strong)NSArray *propertyArray;
@property(nonatomic,strong)Cml_LivingCheckController *livingCheckVc;

-(void)onStart;
-(void)onResume;
-(void)onReset:(int)result :(NSString *)firstTitle :(NSString *)secondTitle;
-(void)onPause;
-(void)onDestroy;

@property(nonatomic, copy)RCTDirectEventBlock onLiving;
@property(nonatomic, copy)RCTDirectEventBlock onSuccess;
@property(nonatomic, copy)RCTDirectEventBlock onError;

@end

NS_ASSUME_NONNULL_END
