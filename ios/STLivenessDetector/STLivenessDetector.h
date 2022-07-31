//
//  STLivenessDetector.h
//  STLivenessDetector
//
//  Created by sluin on 15/12/4.
//  Copyright © 2015年 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "STLivenessDetectorDelegate.h"
#import "STLivenessFaceEnumType.h"
//extern NSInteger const kSenseIdLivenessDefaultTimeOutDuration;
//extern CGFloat const kSenseIdLivenessDefaultHacknessThresholdScore;

@interface STLivenessDetector : NSObject

/**
 *  设置活体对准阶段是否进行眉毛的遮挡检测 , 不设置时默认为NO;
 */

@property (assign, nonatomic) BOOL isBrowOcclusion;




/**
 *  初始化方法
 *  @param detectionModelPathStr          DETECTION 模型资源的路径.
 *  @param alignmentModelPathStr          ALIGNMENT 模型资源的路径.
 *  @param faceQualityModelPathStr       FACEQUALITY 模型资源的路径.
 *  @param frameSelectorModelPathStr      FRAME_SELECTOR 模型资源的路径.
 *  @param licensePathStr                 cml.lic的路径.
 *  @param apiKeyStr                      公有云用户分配一个api key
 *  @param apiSecretStr                   公有云用户分配一个api secret
 *  @param delegate                       回调代理
 *  @param isTracker                      开始检测前是否有对准, YES有对准，NO无对准
 *  @return 活体检测器实例
 */
- (instancetype)initWithDetectionModelPath:(NSString *)detectionModelPathStr
                        alignmentModelPath:(NSString *)alignmentModelPathStr
                      faceQualityModelPath:(NSString *)faceQualityModelPathStr
                    frameSelectorModelPath:(NSString *)frameSelectorModelPathStr
                               licensePath:(NSString *)licensePathStr
                                    apiKey:(NSString *)apiKeyStr
                                 apiSecret:(NSString *)apiSecretStr
                               setDelegate:(id<STLivenessDetectorDelegate>)delegate
                                 isTracker:(BOOL)isTracker;



/**
 *  每个模块允许的最大检测时间
 *
 *  @param duration           每个模块允许的最大检测时间,等于0时为不设置超时时间,默认为10秒,单位是秒.
 */
- (void)setTimeOutDuration:(NSInteger)duration;

/**
 *  活体检测器的难易度
 *
 *  @param complexity         活体检测的复杂度, 默认为 STIDLiveness_COMPLEXITY_NORMAL
 */
- (void)setComplexity:(STIDLivenessFaceComplexity)complexity;

/**
 *  活体检测的阈值
 *
 *  @param score              活体检测的阈值默认为0.95，取值范围 0 < score <= 1
 */
- (void)setHacknessThresholdScore:(CGFloat)score;

/**
 设置人脸远近的判断条件，当参数值不在取值范围内或closeRate不为0且farRate大于closeRate时报错:STIDLiveness_E_INVALID_ARGUMENT。
 @param farRate
 人脸高度/宽度占图像短边的比例，[0.0~1.0]，参数设置越靠近0，代表人脸距离屏幕越远，默认为0.4，如果设置为0，则无过远提示。
 @param closeRate
 人脸高度/宽度占图像短边的比例，[0.0~1.0]，参数设置越靠近1，代表人脸距离屏幕越近，默认为0.8，如果设置为0，则无过近提示。

 */
- (void)setFaceDistanceRateWithFarRate:(CGFloat)farRate closeRate:(CGFloat)closeRate;

/**
 *  获取每个模块允许的最大检测时间
 *
 *  @return                   检测时间，单位是秒
 */
- (NSInteger)timeOutDuration;

/**
 返回难易度

 @return  活体检测的复杂度
 */
- (STIDLivenessFaceComplexity)complexity;

/**
 返回活体检测的阈值

 @return  活体检测的阈值,
 */
- (CGFloat)hacknessThresholdScore;

/**
 对连续输入帧进行人脸跟踪及活体检测

 @param sampleBuffer           每一帧的图像数据
 @param faceOrientation        人脸的朝向
 @param point                  人脸对准目标框（圆的）在图像上的中心点的X和Y
 @param radius                 人脸对准目标框（圆的）在图像上的半径
 @param imagePreviewRect       视频预览框的在图像上的rect
 */
- (void)trackAndDetectWithCMSampleBuffer:(CMSampleBufferRef)sampleBuffer
                          faceOrientaion:(STIDLivenessFaceOrientaion)faceOrientation
                 imagePrepareCenterPoint:(CGPoint)point
                      imagePrepareRadius:(CGFloat)radius
                        imagePreviewRect:(CGRect)imagePreviewRect;
/**
 *  开始检测并设置动作序列
 *
 *  @param detectionArr          动作序列, 如@[@(STIDLiveness_BLINK) ,@(STIDLiveness_MOUTH) ,@(STIDLiveness_NOD)
 * ,@(STIDLiveness_YAW)] , 参照STLivenessFaceEnumType.h
 */
- (void)startDetectionWithDetectionSequenceArray:(NSArray *)detectionArr;

/**
 *  重新开始检测
 */
- (void)reStartDetection;

/**
 *  取消检测
 */

- (void)cancelDetection;

/**
 *  获取SDK版本
 *
 *  @return                     SDK版本
 */

+ (NSString *)getVersion;

/**
 * 获取底层库版本.
 *
 * @return 底层库版本.
 */
+ (NSString *)getLibraryVersion;

@end
