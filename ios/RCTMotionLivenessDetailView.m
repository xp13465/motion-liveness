//
//  RCTMotionLivenessDetailView.m
//  CMChat
//
//  Created by 顔飞 on 2021/3/8.
//  Copyright © 2021 草莓聊. All rights reserved.
//

#import "RCTMotionLivenessDetailView.h"
#define WeakSelf(obj)    __weak   __typeof__(obj) weakSelf   = obj;

@interface RCTMotionLivenessDetailView()

@end

@implementation RCTMotionLivenessDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

-(void)setUI {
    NSLog(@"---setUI");
    self.livingCheckVc = [[Cml_LivingCheckController alloc] init];


    WeakSelf(self);
    self.livingCheckVc.onLivingBlock = ^(){
        NSLog(@"livingCheck onLivingBlock");
        if (weakSelf.onLiving) {
            weakSelf.onLiving(@{});
        }
    };

    self.livingCheckVc.onSuccessBlock = ^(){
        NSLog(@"livingCheck onSuccessBlock");
        if (weakSelf.onSuccess) {
            weakSelf.onSuccess(@{});
        }
    };

    self.livingCheckVc.onFailBlock = ^(){
        NSLog(@"RCTMotionLivenessDetailView livingCheck onFailBlock");
        if (weakSelf.onError) {
            weakSelf.onError(@{});
        }
    };

    [self addSubview:self.livingCheckVc.view];
}

- (void)setPropertyArr:(NSArray *)array {
    _propertyArray = array;
}

//appear
-(void)onResume {
    NSLog(@"---onResume");
    [_livingCheckVc onResume];
}

//disappear
-(void)onPause {
    NSLog(@"---onPause");
}

-(void)onStart {
    NSLog(@"---onStart");
    [_livingCheckVc startLiving];
}


-(void)onReset:(int)result :(NSString *)firstTitle :(NSString *)secondTitle {
    NSLog(@"---onReset");
    [_livingCheckVc resetCheck:result :firstTitle :secondTitle];
}

-(void)onDestroy {
    NSLog(@"---onDestroy");
    [_livingCheckVc stopLiving];
    [self.livingCheckVc.view removeFromSuperview];
}

@end
