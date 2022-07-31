//
//  MotionLiveness.m
//  motionLiving
//
//  Created by 顔飞 on 2021/3/18.
//  Copyright © 2021 Marc Shilling. All rights reserved.
//

#import "MotionLiveness.h"

@implementation MotionLiveness

RCT_EXPORT_MODULE(MotionLiveness);

+ (BOOL)requiresMainQueueSetup
{
  return YES;  // only do this if your module initialization relies on calling UIKit!
}

//为js提供静态数据,执行一次
- (NSDictionary *)constantsToExport
{
    return @{};
}

//模块代码在哪个线程执行
- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue(); //返回一个指定的线程
}

RCT_EXPORT_METHOD(getVideoVerifyPics:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject) {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSMutableArray *imagePaths = [[NSMutableArray alloc] init];
        
    for (int i = 0; i < 4; i++) {
        NSString *imagePath = [NSString stringWithFormat:@"%@/livenessImage%i.jpg", filePath, i];
        ///Library/livenessImage0.jpg
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
//            NSLog(@"---api module getVideoVerifyPics imagePath:%@", imagePath);
            [imagePaths addObject:imagePath];
        }
    }
    
    if (imagePaths.count > 0) {
        resolve(imagePaths);
    } else {
        reject(@"图片获取失败", @"获取图片失败,请重新检测",[NSError errorWithDomain:@"错误" code:1 userInfo:nil]);
    }
}


@end
