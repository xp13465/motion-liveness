//
//  LivingSettingGLobalData.m
//  TestSTLivenessController
//
//  Created by huoqiuliang on 16/9/21.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import "LivingSettingGLobalData.h"
#define k_sequenceArray @"sequenceArray"
#define k_outputType @"outputType"
#define k_liveComplexity @"liveComplexity"
#define k_isVoicePrompt @"isVoicePrompt"

@interface LivingSettingGLobalData ()

@property (nonatomic, strong) NSUserDefaults *userDefault;

@end
@implementation LivingSettingGLobalData

@synthesize sequenceArray = _sequenceArray, outputType = _outputType, liveComplexity = _liveComplexity,
            isVoicePrompt = _isVoicePrompt;

- (NSUserDefaults *)userDefault {
    if (!_userDefault) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    return _userDefault;
}

static LivingSettingGLobalData *gloableData = nil;
+ (LivingSettingGLobalData *)sharedInstanceData {
    @synchronized(self) {
        if (gloableData == nil) {
            gloableData = [[LivingSettingGLobalData alloc] init];
        }
    }
    return gloableData;
}

// ------动作序列
- (NSArray *)sequenceArray {
    _sequenceArray = [self.userDefault objectForKey:k_sequenceArray];
    return _sequenceArray;
}
- (void)setSequenceArray:(NSArray *)sequenceArray {
    [self.userDefault setObject:sequenceArray forKey:k_sequenceArray];
    [self.userDefault synchronize];
}

// ------输出类型

- (NSInteger)outputType {
    _outputType = [self.userDefault integerForKey:k_outputType];
    return _outputType;
}

- (void)setOutputType:(NSInteger)outputType {
    [self.userDefault setInteger:outputType forKey:k_outputType];
    [self.userDefault synchronize];
}

// ------难易程度

- (NSInteger)liveComplexity {
    _liveComplexity = [self.userDefault integerForKey:k_liveComplexity];
    return _liveComplexity;
}

- (void)setLiveComplexity:(NSInteger)liveComplexity {
    [self.userDefault setInteger:liveComplexity forKey:k_liveComplexity];
    [self.userDefault synchronize];
}

// ------提示语音

- (BOOL)isVoicePrompt {
    _isVoicePrompt = [self.userDefault boolForKey:k_isVoicePrompt];
    return _isVoicePrompt;
}
- (void)setIsVoicePrompt:(BOOL)isVoicePrompt {
    [self.userDefault setBool:isVoicePrompt forKey:k_isVoicePrompt];
    [self.userDefault synchronize];
}

@end
