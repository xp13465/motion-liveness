//
//  RCTMotionLivenessView.h
//  CMChat
//
//  Created by 顔飞 on 2021/3/8.
//  Copyright © 2021 草莓聊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTLog.h>
#import "RCTMotionLivenessDetailView.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^liveBlock)(void);

@interface RCTMotionLivenessView : RCTViewManager
@property (nonatomic, strong) RCTMotionLivenessDetailView *detailView;

@end

NS_ASSUME_NONNULL_END
