//
//  STLivenessAudioPlayer.h
//  TestSTLivenessController
//
//  Created by huoqiuliang on 2019/1/15.
//  Copyright © 2019年 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLivenessAudioPlayer : NSObject

@property (nonatomic, strong) NSString *blinkPathString;
@property (nonatomic, strong) NSString *mouthPathString;
@property (nonatomic, strong) NSString *nodPathString;
@property (nonatomic, strong) NSString *yawPathString;
@property (nonatomic, assign) CGFloat currentPlayerVolume;
@property (nonatomic, strong) AVAudioPlayer *currentAudioPlayer;
@property (nonatomic, strong, readonly) AVAudioPlayer *blinkAudioPlayer;
@property (nonatomic, strong, readonly) AVAudioPlayer *mouthAudioPlayer;
@property (nonatomic, strong, readonly) AVAudioPlayer *nodAudioPlayer;
@property (nonatomic, strong, readonly) AVAudioPlayer *yawAudioPlayer;

- (void)startAudioPlayer;

- (void)stopAudioPlayer;

@end

NS_ASSUME_NONNULL_END
