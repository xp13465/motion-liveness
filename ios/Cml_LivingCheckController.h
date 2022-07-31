//
//  Cml_LivingCheckController.h
//  CMChat
//
//  Created by 顔飞 on 2021/3/5.
//  Copyright © 2021 草莓聊. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CheckBlock)(void);

@interface Cml_LivingCheckController : UIViewController
@property(nonatomic,copy)CheckBlock onLivingBlock;
@property(nonatomic,copy)CheckBlock onSuccessBlock;
@property(nonatomic,copy)CheckBlock onFailBlock;
-(void)onResume;
-(void)startLiving;
-(void)resetCheck:(int)result :(NSString *)firstTitle :(NSString *)secondTitle;
-(void)stopLiving;

@end

NS_ASSUME_NONNULL_END
