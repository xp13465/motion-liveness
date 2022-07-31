//
//  RCTMotionLivenessView.m
//  CMChat
//
//  Created by 顔飞 on 2021/3/8.
//  Copyright © 2021 草莓聊. All rights reserved.
//

#import "RCTMotionLivenessView.h"

@interface RCTMotionLivenessView()
@end

@implementation RCTMotionLivenessView

RCT_EXPORT_MODULE(RCTMotionLivenessView)
RCT_EXPORT_VIEW_PROPERTY(onLiving, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSuccess, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)

- (UIView *)view {
    self.detailView = [[RCTMotionLivenessDetailView alloc] init];
    return self.detailView;
}

RCT_EXPORT_METHOD(start:(nonnull NSNumber*) reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        UIView *_Nullable view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[RCTMotionLivenessDetailView class]]) {
            RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
            return;
        }
        
        [(RCTMotionLivenessDetailView *)view onStart];
    }];
}
//reset(number,string,string)  UI复位, -2未提交 -1已驳回 0待审核 1已完成,后面两个字符串是两个title
RCT_EXPORT_METHOD(reset:(nonnull NSNumber*)reactTag :(int)result :(NSString *)firstTitle :(NSString *)secondTitle) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        UIView *_Nullable view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[RCTMotionLivenessDetailView class]]) {
            RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
            return;
        }
        
        [(RCTMotionLivenessDetailView *)view onReset:result :firstTitle :secondTitle];
    }];
}

RCT_EXPORT_METHOD(resume:(nonnull NSNumber*) reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        UIView *_Nullable view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[RCTMotionLivenessDetailView class]]) {
            RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
            return;
        }
        
        [(RCTMotionLivenessDetailView *)view onResume];
    }];
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber*) reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        UIView *_Nullable view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[RCTMotionLivenessDetailView class]]) {
            RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
            return;
        }
        
        [(RCTMotionLivenessDetailView *)view onPause];
    }];
}

RCT_EXPORT_METHOD(destroy:(nonnull NSNumber*) reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        UIView *_Nullable view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[RCTMotionLivenessDetailView class]]) {
            RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
            return;
        }
        
        [(RCTMotionLivenessDetailView *)view onDestroy];
    }];
}

@end
