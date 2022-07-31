//
//  Cml_LivingCheckController.m
//  CMChat
//
//  Created by 顔飞 on 2021/3/5.
//  Copyright © 2021 草莓聊. All rights reserved.
//

#import "Cml_LivingCheckController.h"
#import "STLivenessController.h"
#import "STLivenessDetector.h"
#import "STLivenessCommon.h"
#import "UIView+EX.h"
#import <AVFoundation/AVFoundation.h>
//#import "Reachability.h"

#import "LivingSettingGLobalData.h"

@interface Cml_LivingCheckController ()<STLivenessDetectorDelegate, STLivenessControllerDelegate>

@property (nonatomic, strong) STLivenessController *livenessVC;
@property (nonatomic, copy) NSString *messageString;
@property (nonatomic, assign) BOOL isDone;
@end

@implementation Cml_LivingCheckController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCfg];
    [self setUI];
}

- (void)dealloc {
    NSLog(@"---Cml_LivingCheckController -- dealoc");
}

- (void)setCfg {
    // 设置默认的动作序列为 眨眼 张嘴  点头 摇头
    if (!([LivingSettingGLobalData sharedInstanceData].sequenceArray.count > 0)) {
        [LivingSettingGLobalData sharedInstanceData].sequenceArray =
            @[@(STIDLiveness_BLINK), @(STIDLiveness_MOUTH), @(STIDLiveness_NOD), @(STIDLiveness_YAW)];
        [LivingSettingGLobalData sharedInstanceData].liveComplexity = STIDLiveness_COMPLEXITY_NORMAL;
        [LivingSettingGLobalData sharedInstanceData].isVoicePrompt = YES;
    }
    
    _isDone = NO;
}

- (void)setUI {
    //检测权限
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
//        [[iToast makeText:@"相机权限获取失败:请在设置-隐私-相机中开启后重试"] show];
        return;
    }

    if (!([LivingSettingGLobalData sharedInstanceData].sequenceArray.count > 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"动作序列未设置"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSMutableArray *arrLivenessSequence =
        [NSMutableArray arrayWithArray:[LivingSettingGLobalData sharedInstanceData].sequenceArray];


//    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
//    if (networkStatus == NotReachable) {
//        [[iToast makeText:@"请检查网络连接"] show];
//        return;
//    }
    
    NSString *strApiKey = ACCOUNT_API_KEY;

    NSString *strApiSecret = ACCOUNT_API_SECRET;

    self.livenessVC = [[STLivenessController alloc] initWithApiKey:strApiKey
                                                                          apiSecret:strApiSecret
                                                                        setDelegate:self
                                                                  detectionSequence:arrLivenessSequence];


    //设置每个模块的超时时间
    [_livenessVC.detector setTimeOutDuration:10];
    // 设置活体检测复杂度
    [_livenessVC.detector setComplexity:[LivingSettingGLobalData sharedInstanceData].liveComplexity];
    // 设置活体检测的阈值
    [_livenessVC.detector setHacknessThresholdScore:0.95];

    // 设置是否进行眉毛遮挡的检测，如不设置默认为不检测
    _livenessVC.detector.isBrowOcclusion = NO;

    // 设置默认语音提示状态,如不设置默认为开启
    _livenessVC.isVoicePrompt = [LivingSettingGLobalData sharedInstanceData].isVoicePrompt;
    [self addChildViewController:self.livenessVC];
    [self.view addSubview:self.livenessVC.view];
    CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.livenessVC.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
}

-(void)onResume {
    [_livenessVC resumeLiving];
}

-(void)startLiving {
    if (_isDone) {
        [_livenessVC restartLiving];
    } else {
        [_livenessVC startLiving];
    }
    
    if (self.onLivingBlock) {
        self.onLivingBlock();
    }
}
-(void)resetCheck:(int)result :(NSString *)firstTitle :(NSString *)secondTitle {
    [_livenessVC resetCheck:result :firstTitle :secondTitle];
}

-(void)stopLiving {
    [_livenessVC stopLiving];
}

#pragma - mark STLivenessDetectorDelegate

- (void)livenessDidSuccessfulGetProtobufData:(NSData *)protobufData //! OCLINT
                                   requestId:(NSString *)requestId //! OCLINT
                                      images:(NSArray *)imageArr
                                  statusCode:(NSInteger)statusCode
                           cloudInternalCode:(STIDLivenessCloudInternalCode)cloudInternalCode
    __attribute__((annotate("oclint:suppress[unused method parameter]"))) {
    _isDone = YES;
    if (protobufData.length > 0) {
        [self saveProtobufData:protobufData images:imageArr];
        // 取出每个阶段的图片
        NSMutableArray *resultImageArr = [NSMutableArray array];
        for (STLivenessImage *image in imageArr) {
            [resultImageArr addObject:image.image];
        }
        NSLog(@"--- livenessDidSuccessfulGetProtobufData");
//        [[iToast makeText:@"真人检测成功"] show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.navigationController popViewControllerAnimated:YES];
            if (self.onSuccessBlock) {
                self.onSuccessBlock();
            }
        });
    }
}

/**
 保存数据到沙盒的方法

 @param protobufData protobufData
 @param imageArr 人脸图片数组
 */
- (void)saveProtobufData:(NSData *)protobufData images:(NSArray *)imageArr {
    // 目录下用来离线校验文件内容,在实际场景中应根据实际情况选择处理回传数据
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];;
    //删除之前的图片
    for (int i = 0; i < 4; i++) {
        NSString *imagePath = [NSString stringWithFormat:@"%@/livenessImage%i.jpg", filePath, i];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
//            NSLog(@"---NSFileManager fileExistsAtPath imagePath:%@", imagePath);
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        }
    }

    //写入新图片
    for (int i = 0; i < imageArr.count; i++) {
        STLivenessImage *stImage = imageArr[i];

        NSString *imagePath = [NSString stringWithFormat:@"%@/livenessImage%i.jpg", filePath, i];
//        NSLog(@"--- imagePath:%@", imagePath);
        BOOL writeResult = [UIImageJPEGRepresentation(stImage.image, 1.0) writeToFile:imagePath atomically:YES];
//        NSLog(@"--- imagePath writeResult:%ld", writeResult);
    }
}

- (void)__attribute__((annotate("oclint:suppress")))
livenessDidFailWithLivenessResult:(STIDLivenessResult)livenessResult
faceError:(STIDLivenessFaceError)faceError
protobufData:(NSData *)protobufData
requestId:(NSString *)requestId
images:(NSArray *)imageArr
statusCode:(NSInteger)statusCode
cloudInternalCode:(STIDLivenessCloudInternalCode)cloudInternalCode {
    _isDone = YES;
    NSMutableString *mStr = [NSMutableString string];
    NSString *livenessResultErrorStr = [self messageStringByLivenessResult:livenessResult faceError:faceError];
    [mStr appendString:livenessResultErrorStr];

    if (livenessResult == STIDLiveness_E_API_KEY_INVALID || livenessResult == STIDLiveness_E_SERVER_ACCESS) {
        NSString *cloudErrorStr = [self messageStringBycloudInternalCode:cloudInternalCode];
        [mStr appendString:[NSString
                               stringWithFormat:@"\n CloudInternalCode: %ld \n %@", cloudInternalCode, cloudErrorStr]];
    }

    self.messageString = mStr;

    if (faceError == STIDLiveness_E_FACE_UNKNOWN) {
//        [[iToast makeText:@"人脸的状态未知"] show];
    } else {
//        [[iToast makeText:self.messageString] show];
    }
    NSLog(@"--- livenessDidFailWithLivenessResult:%@", self.messageString);
    [_livenessVC resetCheck:-2 :nil :self.messageString];
    if (self.onFailBlock) {
        self.onFailBlock();
    }
}

- (NSString *)messageStringBycloudInternalCode:(STIDLivenessCloudInternalCode)cloudInternalCode {
    NSString *messageString = @"";
    switch (cloudInternalCode) {
        case STIDLiveness_CLOUD_INTERNAL_DEFAULT: {
            messageString = @"内部错误/未知错误";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_SUCCESS: {
            messageString = @"";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_API_KEY_MISSING: {
            messageString = @"api_key值为空";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_INVALID_API_KEY: {
            messageString = @"无效的api_key";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_API_KEY_IS_DISABLED: {
            messageString = @"api_key被禁用";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_API_KEY_HAS_EXPIRED: {
            messageString = @"api_key已过期 ";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_PERMISSION_DENIED: {
            messageString = @"无该功能权限";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_BUNDLE_ID_MISSING: {
            messageString = @"bundle_id值为空";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_BUNDLE_ID_IS_DISABLED: {
            messageString = @"bundle_id被禁用";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_DAILY_RATE_LIMIT_EXCEEDED: {
            messageString = @"每日调用已达限制";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_APP_SIGN_MISSING: {
            messageString = @"未传入应用签名";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_INVALID_APP_SIGN: {
            messageString = @"应用签名验证失败";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_INVALID_SIGNATURE: {
            messageString = @"数据一致性验证失败";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_INVALID_BUNDLE_ID: {
            messageString = @"bundle_id验证失败";
            break;
        }
        case STIDLiveness_CLOUD_INTERNAL_SENSETIME_ERROR: {
            messageString = @"内部错误，请联系商汤支持人员";
            break;
        }
    }
    return messageString;
}



- (NSString *)messageStringByLivenessResult:(STIDLivenessResult)livenessResult
                                  faceError:(STIDLivenessFaceError)faceError {
    NSString *messageString = @"";
    NSString *description = @"";
    switch (livenessResult) {
        case STIDLiveness_OK: {
            break;
        }
        case STIDLiveness_E_LICENSE_INVALID: {
            messageString = @"未通过授权验证";
            description = @"STIDLiveness_E_LICENSE_INVALID";
            break;
        }
        case STIDLiveness_E_LICENSE_FILE_NOT_FOUND: {
            messageString = @"授权文件不存在";
            description = @"STIDLiveness_E_LICENSE_FILE_NOT_FOUND";
            break;
        }
        case STIDLiveness_E_LICENSE_BUNDLE_ID_INVALID: {
            messageString = @"绑定包名错误";
            description = @"STIDLiveness_E_LICENSE_BUNDLE_ID_INVALID";
            break;
        }
        case STIDLiveness_E_LICENSE_EXPIRE: {
            messageString = @"授权文件过期";
            description = @"STIDLiveness_E_LICENSE_EXPIRE";
            break;
        }
        case STIDLiveness_E_LICENSE_VERSION_MISMATCH: {
            messageString = @"License与SDK版本不匹";
            description = @"STIDLiveness_E_LICENSE_VERSION_MISMATCH";
            break;
        }
        case STIDLiveness_E_LICENSE_PLATFORM_NOT_SUPPORTED: {
            messageString = @"License不支持当前平台";
            description = @"STIDLiveness_E_LICENSE_PLATFORM_NOT_SUPPORTED";
            break;
        }
        case STIDLiveness_E_MODEL_INVALID: {
            messageString = @"模型文件错误";
            description = @"STIDLiveness_E_MODEL_INVALID";
            break;
        }
        case STIDLiveness_E_DETECTION_MODEL_FILE_NOT_FOUND: {
            messageString = @"DETECTION 模型文件不存在";
            description = @"STIDLiveness_E_DETECTION_MODEL_FILE_NOT_FOUND";
            break;
        }
        case STIDLiveness_E_ALIGNMENT_MODEL_FILE_NOT_FOUND: {
            messageString = @"ALIGNMENT 模型文件不存在";
            description = @"STIDLiveness_E_ALIGNMENT_MODEL_FILE_NOT_FOUND";
            break;
        }
        case STIDLiveness_E_FACE_QUALITY_MODEL_FILE_NOT_FOUND: {
            messageString = @"FACE_QUALITY 模型文件不存在";
            description = @"STIDLiveness_E_FACE_QUALITY_MODEL_FILE_NOT_FOUND";
            break;
        }
        case STIDLiveness_E_FRAME_SELECTOR_MODEL_FILE_NOT_FOUND: {
            messageString = @"FRAME_SELECTOR 模型文件不存在";
            description = @"STIDLiveness_E_FRAME_SELECTOR_MODEL_FILE_NOT_FOUND";
            break;
        }
        case STIDLiveness_E_ANTI_SPOOFING_MODEL_FILE_NOT_FOUND: {
            messageString = @"ANTI_SPOOFING 模型文件不存在";
            description = @"STIDLiveness_E_ANTI_SPOOFING_MODEL_FILE_NOT_FOUND";
            break;
        }
        case STIDLiveness_E_MODEL_EXPIRE: {
            messageString = @"模型文件过期";
            description = @"STIDLiveness_E_MODEL_EXPIRE";
            break;
        }
        case STIDLiveness_E_INVALID_ARGUMENT: {
            messageString = @"参数设置不合法";
            description = @"STIDLiveness_E_INVALID_ARGUMENT";
            break;
        }
        case STIDLiveness_E_TIMEOUT: {
            messageString = @"检测超时,请重试一次";
            description = @"STIDLiveness_E_TIMEOUT";
            break;
        }
        case STIDLiveness_E_CALL_API_IN_WRONG_STATE: {
            messageString = @"错误的方法状态调用";
            description = @"STIDLiveness_E_CALL_API_IN_WRONG_STATE";
            break;
        }
        case STIDLiveness_E_FAILED: {
            switch (faceError) {
                case STIDLiveness_E_NOFACE_DETECTED:
                    messageString = @"动作幅度过⼤,请保持人脸在屏幕中央,重试⼀次";
                    description = @"STIDLiveness_E_NOFACE_DETECTED";
                    break;
                case STIDLiveness_E_FACE_OCCLUSION:
                    messageString = @"请调整人脸姿态，去除面部遮挡，正对屏幕重试一次";
                    description = @"STIDLiveness_E_FACE_OCCLUSION";
                    break;
                case STIDLiveness_E_FACE_LIGHT_DARK:
                    messageString = @"光线过暗，请调整光线后，正对屏幕再试一次";
                    description = @"STIDLiveness_E_FACE_LIGHT_DARK";
                    break;
                case STIDLiveness_E_FACE_UNKNOWN: {
                    messageString = @"未通过活体检测";
                    description = @"STIDLiveness_E_FACE_UNKNOWN";
                    break;
                }
            }
            break;
        }
        case STIDLiveness_E_CAPABILITY_NOT_SUPPORTED: {
            messageString = @"授权文件能力不支持";
            description = @"STIDLiveness_E_CAPABILITY_NOT_SUPPORTED";
            break;
        }
        case STIDLiveness_E_API_KEY_INVALID: {
            messageString = @"API账户信息错误";
            description = @"STIDLiveness_E_API_KEY_INVALID";
            break;
        }
        case STIDLiveness_E_SERVER_ACCESS: {
            messageString = @"服务器访问错误";
            description = @"STIDLiveness_E_SERVER_ACCESS";
            break;
        }
        case STIDLiveness_E_SERVER_TIMEOUT: {
            messageString = @"服务器访问超时";
            description = @"STIDLiveness_E_SERVER_TIMEOUT";
            break;
        }
        case STIDLiveness_E_API_KEY_SECRET_NULL: {
            messageString = @"Api key 或者 api secret 为空";
            description = @"STIDLiveness_E_API_KEY_SECRET_NULL";
            break;
        }
        case STIDLiveness_E_HACK: {
            messageString = @"活体检测未通过";
            description = @"STIDLiveness_E_HACK";
            break;
        }
    }

//    if (messageString.length > 0 && description.length > 0) {
//        messageString = [NSString stringWithFormat:@"ResultCode: %@ \n %@", description, messageString];
//    }
    return messageString;
}

- (void)livenessDidCancel {
    self.messageString = @"活体检测已取消";
    NSLog(@"---livenessDidCancel");
    _isDone = YES;
    [_livenessVC resetCheck:-2 :nil :self.messageString];
    if (self.onFailBlock) {
        self.onFailBlock();
    }
//    [[iToast makeText:self.messageString] show];
}

- (void)videoFrameRate:(NSInteger)rate __attribute__((annotate("oclint:suppress[unused method parameter]"))) {
//        printf("%lu FPS\n", rate);
}

- (void)livenessControllerDeveiceError:(STIDLivenessDeveiceError)deveiceError {
    switch (deveiceError) {
        case STIDLiveness_E_CAMERA:
            self.messageString = @"相机权限获取失败:请在设置-隐私-相机中开启后重试";
            break;

        case STIDLiveness_WILL_RESIGN_ACTIVE:
            self.messageString = @"活体检测已经取消";
            break;
    }
    NSLog(@"---livenessControllerDeveiceError");
    [_livenessVC resetCheck:-2 :nil :self.messageString];
    if (self.onFailBlock) {
        self.onFailBlock();
    }
//    [[iToast makeText:self.messageString] show];
}

#pragma mark === NSNotification Action
- (void)arrayActions:(NSNotification *)notification {
    NSDictionary *arryDictionary = [notification userInfo];
    [LivingSettingGLobalData sharedInstanceData].sequenceArray = arryDictionary[@"array"];
}

- (void)liveComplexity:(NSNotification *)notification {
    NSDictionary *arryDictionary = [notification userInfo];
    if ([arryDictionary[@"liveComplexity"] isEqual:@0]) {
        [LivingSettingGLobalData sharedInstanceData].liveComplexity = STIDLiveness_COMPLEXITY_EASY;
    } else if ([arryDictionary[@"liveComplexity"] isEqual:@1]) {
        [LivingSettingGLobalData sharedInstanceData].liveComplexity = STIDLiveness_COMPLEXITY_NORMAL;
    } else if ([arryDictionary[@"liveComplexity"] isEqual:@2]) {
        [LivingSettingGLobalData sharedInstanceData].liveComplexity = STIDLiveness_COMPLEXITY_HARD;
    } else if ([arryDictionary[@"liveComplexity"] isEqual:@3]) {
        [LivingSettingGLobalData sharedInstanceData].liveComplexity = STIDLiveness_COMPLEXITY_HELL;
    }
}

- (void)voicePrompt:(NSNotification *)notification {
    NSDictionary *arryDictionary = [notification userInfo];

    [LivingSettingGLobalData sharedInstanceData].isVoicePrompt = [arryDictionary[@"voicePrompt"] boolValue];
}


@end
