//
//  STLivenessAudioPlayer.m
//  TestSTLivenessController
//
//  Created by huoqiuliang on 2019/1/15.
//  Copyright © 2019年 SenseTime. All rights reserved.
//

#import "STLivenessAudioPlayer.h"

@interface STLivenessAudioPlayer ()
@property (nonatomic, strong, readwrite) AVAudioPlayer *blinkAudioPlayer;
@property (nonatomic, strong, readwrite) AVAudioPlayer *mouthAudioPlayer;
@property (nonatomic, strong, readwrite) AVAudioPlayer *nodAudioPlayer;
@property (nonatomic, strong, readwrite) AVAudioPlayer *yawAudioPlayer;
@end

@implementation STLivenessAudioPlayer

- (void)startAudioPlayer {
    [self stopAudioPlayer];
    [self.currentAudioPlayer play];
}
- (void)stopAudioPlayer {
    if ([self.currentAudioPlayer isPlaying]) {
        self.currentAudioPlayer.currentTime = 0;
        [self.currentAudioPlayer stop];
    }
}
- (void)setBlinkPathString:(NSString *)blinkPathString {
    _blinkPathString = blinkPathString;
    self.blinkAudioPlayer = [self setupAudioPlayerWithURLString:_blinkPathString];
}
- (void)setMouthPathString:(NSString *)mouthPathString {
    _mouthPathString = mouthPathString;
    self.mouthAudioPlayer = [self setupAudioPlayerWithURLString:_mouthPathString];
}

- (void)setNodPathString:(NSString *)nodPathString {
    _nodPathString = nodPathString;
    self.nodAudioPlayer = [self setupAudioPlayerWithURLString:_nodPathString];
}
- (void)setYawPathString:(NSString *)yawPathString {
    _yawPathString = yawPathString;
    self.yawAudioPlayer = [self setupAudioPlayerWithURLString:_yawPathString];
}

- (void)setCurrentPlayerVolume:(CGFloat)currentPlayerVolume {
    _currentPlayerVolume = currentPlayerVolume;

    self.blinkAudioPlayer.volume = _currentPlayerVolume;
    self.mouthAudioPlayer.volume = _currentPlayerVolume;
    self.nodAudioPlayer.volume = _currentPlayerVolume;
    self.yawAudioPlayer.volume = _currentPlayerVolume;
}

- (AVAudioPlayer *)setupAudioPlayerWithURLString:(NSString *)urlString {
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:urlString]
                                                                        error:nil];
    audioPlayer.numberOfLoops = -1;
    [audioPlayer prepareToPlay];
    return audioPlayer;
}

- (void)dealloc {
    if ([_currentAudioPlayer isPlaying]) {
        [_currentAudioPlayer stop];
    }
}
@end
