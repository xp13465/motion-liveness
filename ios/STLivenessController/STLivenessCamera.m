//
//  STLivenessCamera.m
//  TestSTLivenessController
//
//  Created by huoqiuliang on 2019/1/8.
//  Copyright © 2019年 SenseTime. All rights reserved.
//

#import "STLivenessCamera.h"
#import <UIKit/UIKit.h>
#import "STLivenessCommon.h"
@interface STLivenessCamera () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong, readwrite) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *dataOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *deviceFront;
@property (nonatomic, strong) AVCaptureConnection *connection;

@property (nonatomic, assign) STIDLivenessFaceOrientaion faceOrientation;
@property (nonatomic, assign) CGFloat videoHeight;
@property (nonatomic, assign) CGFloat videoWeight;
@property (nonatomic, assign) CGPoint prepareCenterPoint;
@property (nonatomic, assign) CGFloat prepareRadius;
@property (nonatomic, assign) CGRect previewframe;
@end

@implementation STLivenessCamera

- (instancetype)initWithPrepareCenterPoint:(CGPoint)point
                             prepareRadius:(CGFloat)radius
                              previewframe:(CGRect)previewframe {
    self = [super init];
    if (self) {
        _prepareCenterPoint = point;
        _prepareRadius = radius;
        _previewframe = previewframe;
        [self setupCaptureSession];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"camera---dealloc");
    if (_session) {
        [_session beginConfiguration];
        [_session removeOutput:_dataOutput];
        [_session removeInput:_deviceInput];
        [_session commitConfiguration];

        if ([_session isRunning]) {
            [_session stopRunning];
        }
        _session = nil; //! OCLINT
    }
}

- (void)setupCaptureSession {
#if !TARGET_IPHONE_SIMULATOR
    self.session = [[AVCaptureSession alloc] init];
    // iPhone 4S, +
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer =
        [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    captureVideoPreviewLayer.frame = self.previewframe;
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];

    self.captureVideoPreviewLayer = captureVideoPreviewLayer;

    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) { //! OCLINT
            if ([device position] == AVCaptureDevicePositionFront) { //! OCLINT
                self.deviceFront = device;
            }
        }
    }
    int frameRate;
    CMTime frameDuration = kCMTimeInvalid;

    frameRate = 30;
    frameDuration = CMTimeMake(1, frameRate);

    NSError *error = nil;
    if ([self.deviceFront lockForConfiguration:&error]) {
        self.deviceFront.activeVideoMaxFrameDuration = frameDuration;
        self.deviceFront.activeVideoMinFrameDuration = frameDuration;
        [self.deviceFront unlockForConfiguration];
    }

    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.deviceFront error:&error];
    self.deviceInput = input;

    self.dataOutput = [[AVCaptureVideoDataOutput alloc] init];

    [self.dataOutput setAlwaysDiscardsLateVideoFrames:YES];

    //视频的格式只能为kCVPixelFormatType_32BGRA
    [self.dataOutput
        setVideoSettings:@{(id) kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];

    dispatch_queue_t queueBuffer = dispatch_queue_create("LIVENESS_BUFFER_QUEUE", NULL);

    [self.dataOutput setSampleBufferDelegate:self queue:queueBuffer];

    [self.session beginConfiguration];

    if ([self.session canAddOutput:self.dataOutput]) {
        [self.session addOutput:self.dataOutput];
    }
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    // 更改视频方向
    // AVCaptureConnection *connection = [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
    // connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    [self.session commitConfiguration];
#endif
}

- (void)__attribute__((annotate("oclint:suppress")))startRunning {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice
                requestAccessForMediaType:AVMediaTypeVideo
                        completionHandler:^(BOOL granted) {
                            if (granted) {
                                if (self.session && self.dataOutput && ![self.session isRunning]) {
                                    [self.session startRunning];
                                }

                            } else {
                                if (self.delegate &&
                                    [self.delegate respondsToSelector:@selector(cameraAuthorizationFailed)]) {
                                    [self.delegate cameraAuthorizationFailed];
                                }
                            }
                        }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            if (self.session && self.dataOutput && ![self.session isRunning]) {
                [self.session startRunning];
            }
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraAuthorizationFailed)]) {
                [self.delegate cameraAuthorizationFailed];
            }
            break;
        }
    }
}
- (void)stopRunning {
    if (self.session && self.dataOutput && ![self.session isRunning]) {
        [self.session stopRunning];
    }
}

#pragma - mark -
#pragma - mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection
    __attribute__((annotate("oclint:suppress[unused method parameter]"))) {
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef) CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int stride = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    int height = (int) CVPixelBufferGetHeight(pixelBuffer);
    int width = stride / 4;

    size_t top, bottom, left, right;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &left, &right, &top, &bottom);

    width = width + (int) left + (int) right;
    height = height + (int) top + (int) bottom;

    STIDLivenessFaceOrientaion faceOrientation = STIDLiveness_FACE_UP;

    switch (connection.videoOrientation) {
        case AVCaptureVideoOrientationPortrait:

            faceOrientation = STIDLiveness_FACE_UP;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:

            faceOrientation = STIDLiveness_FACE_DOWN;
            break;
        case AVCaptureVideoOrientationLandscapeRight:

            faceOrientation = STIDLiveness_FACE_RIGHT;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:

            faceOrientation = STIDLiveness_FACE_LEFT;
            break;
    }

    self.connection = connection;
    self.faceOrientation = faceOrientation;
    self.videoHeight = height;
    self.videoWeight = width;

    NSDictionary *imageDic = [self convertImageByScreen];
    CGRect imagePreviewRect = CGRectFromString(imageDic[@"imagePreviewRect"]);
    CGPoint imagePrepareCenterPoint = CGPointFromString(imageDic[@"imagePrepareCenterPoint"]);
    CGFloat imagePrepareRadius = [imageDic[@"imagePrepareRadius"] doubleValue];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector
                       (captureOutputSampleBuffer:
                                   faceOrientaion:imagePrepareCenterPoint:imagePrepareRadius:imagePreviewRect:)]) {
        [self.delegate captureOutputSampleBuffer:sampleBuffer
                                  faceOrientaion:faceOrientation
                         imagePrepareCenterPoint:imagePrepareCenterPoint
                              imagePrepareRadius:imagePrepareRadius
                                imagePreviewRect:imagePreviewRect];
    }

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (NSDictionary *)__attribute__((annotate("oclint:suppress")))convertImageByScreen {
    CGFloat imageWidth = self.videoHeight;
    CGFloat imageHeight = self.videoWeight;

    CGFloat screenLeft = self.previewframe.origin.x;
    CGFloat screenRight = self.previewframe.origin.x + self.previewframe.size.width;
    CGFloat screenTop = self.previewframe.origin.y;
    CGFloat screenBottom = self.previewframe.origin.y + self.previewframe.size.height;

    CGFloat imageLeft = 0.0;
    CGFloat imageTop = 0.0;
    CGFloat imageRight = 0.0;
    CGFloat imageBottom = 0.0;
    CGFloat leftSpace = 0.0;
    CGFloat topSpace = 0.0;
    CGFloat screenOnImageScale = 0.0;
    CGPoint imagePrepareCenterPoint = CGPointZero;

    switch (self.faceOrientation) {
        case STIDLiveness_FACE_UP:

            imageRight = self.previewframe.size.width - screenLeft;
            imageLeft = self.previewframe.size.width - screenRight;
            imageTop = screenTop;
            imageBottom = screenBottom;

            screenOnImageScale = MIN(self.previewframe.size.height / imageWidth, //! OCLINT
                                     self.previewframe.size.width / imageHeight); //! OCLINT

            leftSpace = (imageHeight * screenOnImageScale - self.previewframe.size.width) / 2.0;
            topSpace = (imageWidth * screenOnImageScale - self.previewframe.size.height) / 2.0;

            imagePrepareCenterPoint = CGPointMake((self.prepareCenterPoint.x + leftSpace) / screenOnImageScale,
                                                  (self.prepareCenterPoint.y + topSpace) / screenOnImageScale);
            break;

        case STIDLiveness_FACE_DOWN:

            imageRight = screenRight;
            imageLeft = screenLeft;
            imageTop = self.previewframe.size.height - screenBottom;
            imageBottom = self.previewframe.size.height - screenTop;

            screenOnImageScale =
                MIN(self.previewframe.size.height / imageWidth, self.previewframe.size.width / imageHeight); //! OCLINT

            leftSpace = (imageHeight * screenOnImageScale - self.previewframe.size.width) / 2.0;
            topSpace = (imageWidth * screenOnImageScale - self.previewframe.size.height) / 2.0;

            imagePrepareCenterPoint = CGPointMake((self.prepareCenterPoint.x + leftSpace) / screenOnImageScale,
                                                  (self.previewframe.size.height -
                                                   (self.prepareCenterPoint.y + topSpace) / screenOnImageScale));
            break;

        case STIDLiveness_FACE_RIGHT:

            imageLeft = self.previewframe.size.height - screenBottom;
            imageRight = self.previewframe.size.height - screenTop;
            imageTop = screenLeft;
            imageBottom = screenRight;

            screenOnImageScale = MIN(self.previewframe.size.height / imageHeight, //! OCLINT
                                     self.previewframe.size.width / imageWidth); //! OCLINT

            topSpace = (imageWidth * screenOnImageScale - self.previewframe.size.width) / 2.0;
            leftSpace = (imageHeight * screenOnImageScale - self.previewframe.size.height) / 2.0;

            imagePrepareCenterPoint = CGPointMake((self.previewframe.size.height -
                                                   (self.prepareCenterPoint.y + leftSpace) / screenOnImageScale),
                                                  (self.prepareCenterPoint.x + topSpace) / screenOnImageScale);

            break;

        case STIDLiveness_FACE_LEFT:

            imageLeft = screenTop;
            imageRight = screenBottom;
            imageTop = screenLeft;
            imageBottom = screenRight;
            screenOnImageScale = MIN(self.previewframe.size.height / imageHeight, //! OCLINT
                                     self.previewframe.size.width / imageWidth); //! OCLINT
            topSpace = (imageWidth * screenOnImageScale - self.previewframe.size.width) / 2.0;
            leftSpace = (imageHeight * screenOnImageScale - self.previewframe.size.height) / 2.0;

            imagePrepareCenterPoint = CGPointMake((self.prepareCenterPoint.y + leftSpace) / screenOnImageScale,
                                                  (self.prepareCenterPoint.x + topSpace) / screenOnImageScale);
            break;
    }

    CGRect imagePreviewRect = CGRectMake((imageLeft + leftSpace) / screenOnImageScale,
                                         (imageTop + topSpace) / screenOnImageScale,
                                         (imageRight - imageLeft) / screenOnImageScale,
                                         (imageBottom - imageTop) / screenOnImageScale);

    CGFloat imagePrepareRadius = self.prepareRadius / screenOnImageScale;

    return @{
        @"imagePreviewRect": NSStringFromCGRect(imagePreviewRect),
        @"imagePrepareCenterPoint": NSStringFromCGPoint(imagePrepareCenterPoint),
        @"imagePrepareRadius": @(imagePrepareRadius),
    };
}

- (CGRect)convertScreenRectByImageRect:(CGRect)imagePreviewRect {
    CGFloat imageOnPreviewScale;
    CGRect screenPreviewRect;
    CGFloat imageWidth = self.videoHeight;
    CGFloat imageHeight = self.videoWeight;

    CGFloat imagePreviewLeft = imagePreviewRect.origin.x;
    CGFloat imagePreviewTop = imagePreviewRect.origin.y;
    CGFloat imagePreviewRight = imagePreviewRect.size.width + imagePreviewRect.origin.x;
    CGFloat imagePreviewBottom = imagePreviewRect.size.height + imagePreviewRect.origin.y;

    CGFloat screenPreviewLeft = 0.0;
    CGFloat screenPreviewTop = 0.0;
    CGFloat screenPreviewRight = 0.0;
    CGFloat screenPreviewBottom = 0.0;

    CGFloat leftSpace = 0.0;
    CGFloat topSpace = 0.0;

    switch (self.faceOrientation) {
        case STIDLiveness_FACE_UP:

            screenPreviewLeft = imageHeight - imagePreviewRight;
            screenPreviewRight = imageHeight - imagePreviewLeft;
            screenPreviewTop = imagePreviewTop;
            screenPreviewBottom = imagePreviewBottom;

            imageOnPreviewScale = MIN(self.previewframe.size.height / imageWidth, //! OCLINT
                                      self.previewframe.size.width / imageHeight); //! OCLINT

            leftSpace = (imageHeight * imageOnPreviewScale - self.previewframe.size.width) / 2.0;
            topSpace = (imageWidth * imageOnPreviewScale - self.previewframe.size.height) / 2.0;
            break;

        case STIDLiveness_FACE_DOWN:

            screenPreviewLeft = imagePreviewRight;
            screenPreviewRight = imagePreviewLeft;
            screenPreviewTop = imageWidth - imagePreviewTop;
            screenPreviewBottom = imageWidth - imagePreviewBottom;

            imageOnPreviewScale =
                MIN(self.previewframe.size.height / imageWidth, self.previewframe.size.width / imageHeight); //! OCLINT

            leftSpace = (imageHeight * imageOnPreviewScale - self.previewframe.size.width) / 2.0;
            topSpace = (imageWidth * imageOnPreviewScale - self.previewframe.size.height) / 2.0;
            break;

        case STIDLiveness_FACE_RIGHT:

            screenPreviewTop = imageHeight - imagePreviewLeft;
            screenPreviewBottom = imageHeight - imagePreviewRight;
            screenPreviewLeft = imageWidth - imagePreviewTop;
            screenPreviewRight = imageWidth - imagePreviewBottom;

            imageOnPreviewScale = MIN(self.previewframe.size.height / imageHeight, //! OCLINT
                                      self.previewframe.size.width / imageWidth); //! OCLINT

            leftSpace = (imageWidth * imageOnPreviewScale - self.previewframe.size.width) / 2.0;
            topSpace = (imageHeight * imageOnPreviewScale - self.previewframe.size.height) / 2.0;

            break;

        case STIDLiveness_FACE_LEFT:

            screenPreviewTop = imagePreviewLeft;
            screenPreviewBottom = imagePreviewRight;
            screenPreviewLeft = imagePreviewTop;
            screenPreviewRight = imagePreviewBottom;

            imageOnPreviewScale = MIN(self.previewframe.size.height / imageHeight, //! OCLINT
                                      self.previewframe.size.width / imageWidth); //! OCLINT

            leftSpace = (imageWidth * imageOnPreviewScale - self.previewframe.size.width) / 2.0;
            topSpace = (imageHeight * imageOnPreviewScale - self.previewframe.size.height) / 2.0;

            break;
    }

    screenPreviewRect = CGRectMake(imageOnPreviewScale * screenPreviewLeft - leftSpace,
                                   imageOnPreviewScale * screenPreviewTop - topSpace,
                                   imageOnPreviewScale * (screenPreviewRight - screenPreviewLeft),
                                   imageOnPreviewScale * (screenPreviewBottom - screenPreviewTop));

    return screenPreviewRect;
}

@end
