//
//  STLivenessCamera.h
//  TestSTLivenessController
//
//  Created by huoqiuliang on 2019/1/8.
//  Copyright © 2019年 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "STLivenessFaceEnumType.h"

@protocol STLivenessCameraDelegate <NSObject>
- (void)captureOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                   faceOrientaion:(STIDLivenessFaceOrientaion)faceOrientation
          imagePrepareCenterPoint:(CGPoint)imagePrepareCenterPoint
               imagePrepareRadius:(CGFloat)imagePrepareRadius
                 imagePreviewRect:(CGRect)imagePreviewRect;

- (void)cameraAuthorizationFailed;

@end

@interface STLivenessCamera : NSObject

/**
 初始化相机类
 @param point  人脸对准目标框（圆的）在屏幕上的中心点的X和Y
 @param radius 人脸对准目标框（圆的）在屏幕上的半径
 @param previewframe 视频预览框在屏幕上的frame
 @return 相机实例对象
 */
- (instancetype)initWithPrepareCenterPoint:(CGPoint)point
                             prepareRadius:(CGFloat)radius
                              previewframe:(CGRect)previewframe;

@property (nonatomic, weak) id<STLivenessCameraDelegate> delegate;

@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

- (void)startRunning;

- (void)stopRunning;

- (CGRect)convertScreenRectByImageRect:(CGRect)imagePreviewRect;

@end
