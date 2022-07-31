//
//  STLivenessController.m
//  STLivenessController
//
//  Created by sluin on 15/12/4.
//  Copyright © 2015年 SenseTime. All rights reserved.
//

#import "STLivenessController.h"
#import "STLivenessDetector.h"
#import "STLivenessCommon.h"
#import "STLivenessCamera.h"
#import "STLivenessAudioPlayer.h"

#import "STStartAndStopIndicatorView.h"

#import "STLivenessView.h"
#import "UIView+EX.h"

//摄像区域间隔
#define CICLE_TO_LEFT (IS_IPHONE ? 50 : 70 * 2)

#define CICLE_TO_WH (kSTScreenWidth - CICLE_TO_LEFT * 2)

#define PHONE_CICLE_TO_TOP 10
//#define PHONE_CICLE_TO_TOP ([[UIApplication sharedApplication] statusBarFrame].size.height + 44) + 40

@interface STLivenessController () <STLivenessDetectorDelegate, STLivenessCameraDelegate> {
    NSArray *_detectionArr;
    NSMutableArray *_previousSecondTimestamps;
}

@property (nonatomic, weak) id<STLivenessControllerDelegate> controllerDelegate;
@property (nonatomic, weak) id<STLivenessDetectorDelegate> delegate;

@property (nonatomic, strong) STLivenessView *livenessView;

@property (nonatomic, strong) STStartAndStopIndicatorView *indicatorView;

@property (nonatomic, strong) STLivenessCamera *livenessCamera;
@property (nonatomic, strong) STLivenessAudioPlayer *livenessAudioPlayer;

@property (nonatomic, copy) NSString *bundlePathStr;
@property (nonatomic, copy) NSString *resourcesBundlePathStr;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSOperationQueue *mainQueue;
@property (nonatomic, assign) CFAbsoluteTime lastUpdateTime;

@property (nonatomic, assign) CGFloat prepareCenterX;
@property (nonatomic, assign) CGFloat prepareCenterY;
@property (nonatomic, assign) CGFloat prepareRadius;

@property (nonatomic, assign) CGRect previewframe;
@property (nonatomic, assign) CGRect circleRect;

@property (nonatomic, assign) BOOL is3_5InchScreen;
@property (nonatomic, assign) BOOL isCameraPermission;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation STLivenessController

- (instancetype)init {
    NSLog(@" ╔—————————————————————— WARNING —————————————————————╗");
    NSLog(@" | [[STLivenessController alloc] init] is not allowed |");
    NSLog(@" |     Please use  \"initWithApiKey\" , thanks !    |");
    NSLog(@" ╚————————————————————————————————————————————————————╝");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma - mark -
#pragma - mark Public method

- (instancetype)initWithApiKey:(NSString *)apiKeyStr
                     apiSecret:(NSString *)apiSecretStr
                   setDelegate:(id<STLivenessDetectorDelegate, STLivenessControllerDelegate>)delegate
             detectionSequence:(NSArray *)detectionArr {
    self = [super init];

    if (self) {
        if (_delegate != delegate) {
            _delegate = delegate;
        }
        if (_controllerDelegate != delegate) {
            _controllerDelegate = delegate;
        }
        _mainQueue = [NSOperationQueue mainQueue];
        if (!detectionArr) {
            NSLog(@" ╔———————————— WARNING ————————————╗");
            NSLog(@" |                                 |");
            NSLog(@" |  Please set detection sequence !|");
            NSLog(@" |                                 |");
            NSLog(@" ╚—————————————————————————————————╝");
        } else {
            // 资源路径
            NSBundle *motionBundle = [NSBundle bundleForClass:[self class]];
            _bundlePathStr = [motionBundle pathForResource:@"st_liveness_resource" ofType:@"bundle"];
#pragma lic路径

            NSString *licensePathStr;

            NSString *identifier  = [[NSBundle mainBundle] bundleIdentifier];

            if ([identifier isEqualToString:@"com.hjhy.chat"]) {
                licensePathStr = [[NSBundle mainBundle] pathForResource:@"huayin" ofType:@"lic"];
            } else if ([identifier isEqualToString:@"com.chain.future"]) {
                licensePathStr = [[NSBundle mainBundle] pathForResource:@"cml-tf" ofType:@"lic"];
            } else if ([identifier isEqualToString:@"com.weiliancm.chat"]) {
                licensePathStr = [[NSBundle mainBundle] pathForResource:@"cml-dev" ofType:@"lic"];
            } else if ([identifier isEqualToString:@"com.caomei.yumeng"]) {
                licensePathStr = [[NSBundle mainBundle] pathForResource:@"cml-ym-appstore" ofType:@"lic"];
            } else {
                //默认yitu.lic
                licensePathStr = [[NSBundle mainBundle] pathForResource:@"yitu" ofType:@"lic"];
            }
            
            if (!licensePathStr) {
                NSLog(@"没有发现lic identifier：%@", identifier);
            } else {
                NSLog(@"identifier:%@, lic path：%@", identifier, licensePathStr);
            }
            
            // 模型路径
            NSString *detectionModelPathStr =
                [NSString pathWithComponents:@[self.bundlePathStr, @"model", @"M_Detect_Hunter_SmallFace.model"]];

            NSString *alignmentModelPathStr =
                [NSString pathWithComponents:@[self.bundlePathStr, @"model", @"M_Align_occlusion.model"]];

            NSString *faceQualityModelPathStr = [NSString
                pathWithComponents:@[self.bundlePathStr, @"model", @"M_Face_Quality_Assessment_Mobile.model"]];

            NSString *frameSelectorModelPathStr =
                [NSString pathWithComponents:@[self.bundlePathStr, @"model", @"M_Liveness_Cnn_half.model"]];

            CGFloat previewHeight = kSTScreenWidth / 3 * 4;

//            self.previewframe = CGRectMake(0, 0, kSTScreenWidth, previewHeight);
            self.previewframe = CGRectMake(0, 0, kSTScreenWidth, kSTScreenWidth);

            if (IS_IPHONE) {
                self.prepareRadius = CICLE_TO_WH / 3;
                self.circleRect = CGRectMake(CICLE_TO_LEFT, PHONE_CICLE_TO_TOP, CICLE_TO_WH, CICLE_TO_WH);

            } else {
                self.prepareRadius = CICLE_TO_WH / 3;
                self.circleRect = CGRectMake(CICLE_TO_LEFT, PHONE_CICLE_TO_TOP * 2, CICLE_TO_WH, CICLE_TO_WH);
            }
            self.prepareCenterX = _previewframe.size.width / 2.0;
            self.prepareCenterY = self.circleRect.origin.y + self.circleRect.size.width / 2;
            _detector = [[STLivenessDetector alloc] initWithDetectionModelPath:detectionModelPathStr
                                                            alignmentModelPath:alignmentModelPathStr
                                                          faceQualityModelPath:faceQualityModelPathStr
                                                        frameSelectorModelPath:frameSelectorModelPathStr
                                                                   licensePath:licensePathStr
                                                                        apiKey:apiKeyStr
                                                                     apiSecret:apiSecretStr
                                                                   setDelegate:self
                                                                     isTracker:YES];
            //设置人脸远近判断条件
            [_detector setFaceDistanceRateWithFarRate:0.3 closeRate:0.7];
        }
        _isVoicePrompt = YES;

        _detectionArr = [detectionArr mutableCopy];

        _previousSecondTimestamps = [[NSMutableArray alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}


- (void)setIsVoicePrompt:(BOOL)isVoicePrompt {
    _isVoicePrompt = isVoicePrompt;
}

#pragma - mark -
#pragma - mark Life Cycle

- (void)loadView {
    [super loadView];
    self.is3_5InchScreen = (kSTScreenHeight == 480);
    [self addLivenessView];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIBarButtonItem *backItem =
//        [[UIBarButtonItem alloc] initWithImage:[[self imageWithFullFileName:@"st_scan_back.png"]
//                                                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
//                                         style:UIBarButtonItemStylePlain
//                                        target:self
//                                        action:@selector(onBack)];
//    self.navigationItem.leftBarButtonItem = backItem;
//    self.navigationItem.title = @"交互活体";

    self.livenessCamera =
        [[STLivenessCamera alloc] initWithPrepareCenterPoint:CGPointMake(self.prepareCenterX, self.prepareCenterY)
                                               prepareRadius:self.prepareRadius
                                                previewframe:self.previewframe];
    self.livenessCamera.delegate = self;

    [self.view.layer addSublayer:self.livenessCamera.captureVideoPreviewLayer];
    [self.view bringSubviewToFront:self.livenessView];

    self.livenessAudioPlayer = [[STLivenessAudioPlayer alloc] init];
    self.livenessAudioPlayer.blinkPathString = [self audioPathWithFullFileName:@"st_notice_blink.mp3"];
    self.livenessAudioPlayer.mouthPathString = [self audioPathWithFullFileName:@"st_notice_mouth.mp3"];
    self.livenessAudioPlayer.nodPathString = [self audioPathWithFullFileName:@"st_notice_nod.mp3"];
    self.livenessAudioPlayer.yawPathString = [self audioPathWithFullFileName:@"st_notice_yaw.mp3"];
    self.livenessAudioPlayer.currentPlayerVolume = self.isVoicePrompt ? 0.8 : 0;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.circleRect.origin.x-2, self.circleRect.origin.y-2, self.circleRect.size.width+4, self.circleRect.size.height+4)];
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageView];
    [self.view bringSubviewToFront:self.imageView];
    self.imageView.hidden = NO;
    NSLog(@"---STLivenessController  viewDidLoad");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    if (self.detector) {
//        [self.livenessCamera startRunning];
//    }
}
- (void)dealloc {
    NSLog(@"---STLivenessController  dealloc");
    [self.livenessCamera stopRunning];
    [self.livenessAudioPlayer stopAudioPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma - mark -
#pragma - mark Private Methods_

- (void)willResignActive {
    [self clearStepViewAndStopSoundInvalidateTimer];
    if (self.controllerDelegate &&
        [self.controllerDelegate respondsToSelector:@selector(livenessControllerDeveiceError:)] &&
        self.isCameraPermission) {
        [self.mainQueue addOperationWithBlock:^{
            [self.controllerDelegate livenessControllerDeveiceError:STIDLiveness_WILL_RESIGN_ACTIVE];
        }];
    }

    [self.indicatorView indicatorStopAnimate];

}

-(void)resumeLiving {

}

-(void)startLiving {
    if (self.detector) {
        self.imageView.hidden = YES;
        [self.livenessCamera startRunning];
        self.livenessView.maskCoverView.lineColor = [UIColor purpleColor];
    }
}

-(void)restartLiving {
    if (self.detector) {
        self.imageView.hidden = YES;
        [self addLivenessView];
        [self.detector reStartDetection];
        self.livenessView.maskCoverView.lineColor = [UIColor purpleColor];
    }
}

-(void)resetCheck:(int)result :(NSString *)firstTitle :(NSString *)secondTitle {
    [self addLivenessView];
    // -2未提交 -1已驳回 0待审核 1已完成,后面两个字符串是两个title
    NSLog(@"---resetCheck  firstTitle:%@,secondTitle:%@", firstTitle, secondTitle);
    NSString *imageName = @"";
    
    if (result == -2) {
        imageName = @"verify_default";
    } else if (result == -1) {
        imageName = @"verify_fail";
    } else if (result == 0) {
        imageName = @"verify_doing";
    } else if (result == 1) {
        imageName = @"verify_ok";
    }
    NSBundle *motionBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePathStr = [NSString pathWithComponents:@[
        [motionBundle pathForResource:@"st_liveness_resource" ofType:@"bundle"],
        @"images",
        imageName
    ]];
    self.imageView.image = [UIImage imageWithContentsOfFile:filePathStr];
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.hidden = NO;
    
    if (firstTitle != nil && secondTitle != nil) {
        NSLog(@"---resetCheck  firstTitle&&secondTitle");
        self.livenessView.hintLabel.text = firstTitle;
        self.livenessView.resultLabel.text = secondTitle;
    } else if (firstTitle != nil) {
        NSLog(@"---resetCheck  firstTitle");
        self.livenessView.hintLabel.text = firstTitle;
    } else if (secondTitle != nil) {
        NSLog(@"---resetCheck  secondTitle");
        self.livenessView.resultLabel.text = secondTitle;
    }
    
    self.livenessView.maskCoverView.lineColor = [UIColor clearColor];
}

-(void)stopLiving {
    self.livenessView.maskCoverView.lineColor = [UIColor clearColor];
    [self.livenessCamera stopRunning];
    [self.livenessAudioPlayer stopAudioPlayer];
}

- (UIImage *)imageWithFullFileName:(NSString *)fileNameStr {
    NSString *filePathStr = [NSString pathWithComponents:@[self.bundlePathStr, @"images", fileNameStr]];

    return [UIImage imageWithContentsOfFile:filePathStr];
}

- (NSString *)audioPathWithFullFileName:(NSString *)fileNameStr {
    NSString *filePathStr = [NSString pathWithComponents:@[self.bundlePathStr, @"sounds", fileNameStr]];
    return filePathStr;
}
- (void)showPromptWithDetectionType:(STIDLivenessFaceDetectionType)iType detectionIndex:(NSInteger)index {
    if (self.livenessAudioPlayer.currentAudioPlayer) {
        [self.livenessAudioPlayer stopAudioPlayer];
    }
//    if (index == 0) {
//        [self.livenessView startAnimation];
//    }
//    [self.livenessView nextMotion];
    switch (iType) {
        case STIDLiveness_YAW: {
            self.livenessView.hintLabel.text = @"请缓慢摇头";
            self.livenessAudioPlayer.currentAudioPlayer = self.livenessAudioPlayer.yawAudioPlayer;
            break;
        }

        case STIDLiveness_BLINK: {
            self.livenessView.hintLabel.text = @"请眨眼";
            self.livenessAudioPlayer.currentAudioPlayer = self.livenessAudioPlayer.blinkAudioPlayer;
            break;
        }

        case STIDLiveness_MOUTH: {
            self.livenessView.hintLabel.text = @"请张嘴，随后合拢";
            self.livenessAudioPlayer.currentAudioPlayer = self.livenessAudioPlayer.mouthAudioPlayer;
            break;
        }
        case STIDLiveness_NOD: {
            self.livenessView.hintLabel.text = @"请上下点头";
            self.livenessAudioPlayer.currentAudioPlayer = self.livenessAudioPlayer.nodAudioPlayer;
            break;
        }
    }

    if (self.livenessAudioPlayer.currentAudioPlayer) {
        [self.livenessAudioPlayer startAudioPlayer];
    }
}

- (void)clearStepViewAndStopSoundInvalidateTimer {
    if (self.livenessAudioPlayer.currentAudioPlayer) {
        [self.livenessAudioPlayer stopAudioPlayer];
    }
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    [self.mainQueue addOperationWithBlock:^{
        self.livenessView.hintLabel.text = @"";
        self.livenessView.resultLabel.text = @"";
    }];
}
#pragma - mark -
#pragma - mark Event Response

- (void)onBack {
    self.isCameraPermission = NO;
    [self.detector cancelDetection];
}
#pragma - mark -
#pragma - mark STLivenessCameraDelegate
- (void)captureOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                   faceOrientaion:(STIDLivenessFaceOrientaion)faceOrientation
          imagePrepareCenterPoint:(CGPoint)imagePrepareCenterPoint
               imagePrepareRadius:(CGFloat)imagePrepareRadius
                 imagePreviewRect:(CGRect)imagePreviewRect {
    self.isCameraPermission = YES;
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoFrameRate:)]) {
        [self.delegate videoFrameRate:[self calculateFramerateAtTimestamp:timestamp]];
    }

    if (self.detector) {
        [self.detector trackAndDetectWithCMSampleBuffer:sampleBuffer
                                         faceOrientaion:faceOrientation
                                imagePrepareCenterPoint:imagePrepareCenterPoint
                                     imagePrepareRadius:imagePrepareRadius
                                       imagePreviewRect:imagePreviewRect];
    }
}
- (void)cameraAuthorizationFailed {
    if (self.controllerDelegate &&
        [self.controllerDelegate respondsToSelector:@selector(livenessControllerDeveiceError:)]) {
        [self.mainQueue addOperationWithBlock:^{
            [self.controllerDelegate livenessControllerDeveiceError:STIDLiveness_E_CAMERA];
        }];
    }
}

- (int)calculateFramerateAtTimestamp:(CMTime)timestamp {
    [_previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];

    CMTime oneSecond = CMTimeMake(1, 1);
    CMTime oneSecondAgo = CMTimeSubtract(timestamp, oneSecond);

    while (CMTIME_COMPARE_INLINE([_previousSecondTimestamps[0] CMTimeValue], <, oneSecondAgo)) {
        [_previousSecondTimestamps removeObjectAtIndex:0];
    }

    if ([_previousSecondTimestamps count] > 1) {
        const Float64 duration = CMTimeGetSeconds(CMTimeSubtract([[_previousSecondTimestamps lastObject] CMTimeValue],
                                                                 [_previousSecondTimestamps[0] CMTimeValue]));
        const float newRate = (float) ([_previousSecondTimestamps count] - 1) / duration;
        return (int) roundf(newRate);
    }
    return 0;
}
#pragma - mark -
#pragma - mark STLivenessDetectorDelegate

- (void)livenessFaceImageRect:(CGRect)imageRect {
    if (self.delegate && [self.delegate respondsToSelector:@selector(livenessFaceImageRect:)]) {
        [self.mainQueue addOperationWithBlock:^{
            [self.delegate livenessFaceImageRect:imageRect];
        }];
    }
    //人脸在屏幕上的rect
    //[self.livenessCamera convertScreenRectByImageRect:imageRect];
}

- (void)livenessTrackerSuccessed {
    if (self.livenessCamera && self.detector && self.livenessAudioPlayer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(startDetection)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}
- (void)startDetection {
    self.livenessView.lineColor = kSTColorWithRGB(0xcc9233);
    [self.detector startDetectionWithDetectionSequenceArray:_detectionArr];
}
- (void)livenessTrackerDistanceStatus:(STIDLivenessFaceDistanceStatus)distanceStatus
                          boundStatus:(STIDLivenessFaceBoundStatus)boundStatus
                            faceModel:(STLivenessFace *)faceModel {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent() * 1000;

    if ((currentTime - self.lastUpdateTime) > 300) {
        if (faceModel.isOcclusion) {
            self.livenessView.hintLabel.text = [self faceOcclusionStringWithFaceModel:faceModel];

        } else if (faceModel.isFaceLightDark) {
            self.livenessView.hintLabel.text = @"当前光线过暗，请调整光线";
        } else if (distanceStatus == STIDLiveness_FACE_TOO_FAR) {
            self.livenessView.hintLabel.text = @"请移动手机靠近面部";
        } else if (distanceStatus == STIDLiveness_FACE_TOO_CLOSE) {
            self.livenessView.hintLabel.text = @"请移动手机远离面部";
        } else if (distanceStatus == STIDLiveness_DISTANCE_FACE_NORMAL && boundStatus == STIDLiveness_FACE_IN_BOUNDE) {
            self.livenessView.hintLabel.text = @"准备开始检测";

        } else {
            self.livenessView.hintLabel.text = @"请将人脸移入框内";
        }
        self.lastUpdateTime = CFAbsoluteTimeGetCurrent() * 1000;
    }
}

- (NSString *)faceOcclusionStringWithFaceModel:(STLivenessFace *)face {
    NSMutableString *tempStr = [[NSMutableString alloc] init];

    if (face.browOcclusionStatus == STIDLiveness_OCCLUSION) {
        [tempStr appendFormat:@"眉毛、"];
    }
    if (face.eyeOcclusionStatus == STIDLiveness_OCCLUSION) {
        [tempStr appendFormat:@"眼睛、"];
    }
    if (face.noseOcclusionStatus == STIDLiveness_OCCLUSION) {
        [tempStr appendFormat:@"鼻子、"];
    }
    if (face.mouthOcclusionStatus == STIDLiveness_OCCLUSION) {
        [tempStr appendFormat:@"嘴巴"];
    }
    NSString *theLast = [tempStr substringFromIndex:[tempStr length] - 1];
    if ([theLast isEqualToString:@"、"]) {
        tempStr = (NSMutableString *) [tempStr substringToIndex:([tempStr length] - 1)];
    }
    return [NSString stringWithFormat:@"请正对手机，去除%@遮挡", tempStr];
}
- (void)livenessDidStartDetectionWithDetectionType:(STIDLivenessFaceDetectionType)detectionType
                                    detectionIndex:(NSInteger)detectionIndex {
    [self showPromptWithDetectionType:detectionType detectionIndex:detectionIndex];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(livenessDidStartDetectionWithDetectionType:detectionIndex:)]) {
        [self.mainQueue addOperationWithBlock:^{
            [self.delegate livenessDidStartDetectionWithDetectionType:detectionType detectionIndex:detectionIndex];
        }];
    }
}


- (void)livenessOnlineBegin {
    [self clearStepViewAndStopSoundInvalidateTimer];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView indicatorStartAnimate];
//    self.indicatorView.hidden = YES;
}
- (void)livenessDidSuccessfulGetProtobufData:(NSData *)protobufData
                                   requestId:(NSString *)requestId
                                      images:(NSArray *)imageArr
                                  statusCode:(NSInteger)statusCode
                           cloudInternalCode:(STIDLivenessCloudInternalCode)cloudInternalCode {
    [self clearStepViewAndStopSoundInvalidateTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector
                       (livenessDidSuccessfulGetProtobufData:requestId:images:statusCode:cloudInternalCode:)]) {
        [self.mainQueue addOperationWithBlock:^{
            [self.delegate livenessDidSuccessfulGetProtobufData:protobufData
                                                      requestId:requestId
                                                         images:imageArr
                                                     statusCode:statusCode
                                              cloudInternalCode:cloudInternalCode];
        }];
    }
    [self.indicatorView indicatorStopAnimate];
}

- (void)livenessDidFailWithLivenessResult:(STIDLivenessResult)livenessResult
                                faceError:(STIDLivenessFaceError)faceError
                             protobufData:(NSData *)protobufData
                                requestId:(NSString *)requestId
                                   images:(NSArray *)imageArr
                               statusCode:(NSInteger)statusCode
                        cloudInternalCode:(STIDLivenessCloudInternalCode)cloudInternalCode {
    [self clearStepViewAndStopSoundInvalidateTimer];
    // 重新开始检测
    //    if (faceError == STIDLiveness_E_NOFACE_DETECTED) {
    //        _detectionArr = @[@(STIDLiveness_MOUTH), @(STIDLiveness_BLINK)];
    //        [self addLivenessView];
    //        [self.detector reStartDetection];
    //        return;
    //    }

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(livenessDidFailWithLivenessResult:
                                                                            faceError:protobufData:requestId:images
                                                                                     :statusCode:cloudInternalCode:)]) {
        [self.mainQueue addOperationWithBlock:^{
            [self.delegate livenessDidFailWithLivenessResult:livenessResult
                                                   faceError:faceError
                                                protobufData:protobufData
                                                   requestId:requestId
                                                      images:imageArr
                                                  statusCode:statusCode
                                           cloudInternalCode:cloudInternalCode];
        }];
    }
    [self.indicatorView indicatorStopAnimate];
}

- (void)livenessDidCancel {
    [self clearStepViewAndStopSoundInvalidateTimer];
    if (self.delegate && [self.delegate respondsToSelector:@selector(livenessDidCancel)]) {
        [self.mainQueue addOperationWithBlock:^{
            [self.delegate livenessDidCancel];
        }];
    }

    [self.indicatorView indicatorStopAnimate];

}


- (STStartAndStopIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[STStartAndStopIndicatorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _indicatorView;
}

- (void)addLivenessView {
    [self.livenessView removeFromSuperview];
    self.livenessView = [[STLivenessView alloc] initWithFrame:CGRectMake(0, 0, kSTScreenWidth, kSTScreenHeight)];
    self.livenessView.hintLabel.text = @"";
    self.livenessView.resultLabel.text = @"";
    self.livenessView.detectionArr = [_detectionArr mutableCopy];

    self.livenessView.circleRect = self.circleRect;
    [self.view addSubview:self.livenessView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
