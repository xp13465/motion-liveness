//
//  STLivenessCommon.h
//  STLivenessController
//
//  Created by sluin on 15/12/4.
//  Copyright © 2015年 SenseTime. All rights reserved.
//

#ifndef STLivenessCommon_h
#define STLivenessCommon_h

//#error 请将账户信息补全，然后删除此行。Fill in your account info below, and delete this line.
#define ACCOUNT_API_KEY @"5795cb839ce943cfb08159f0e42a8f9f"
#define ACCOUNT_API_SECRET @"61f78cc79f884e1ba9f3042e9fa67bfd"


#define kSTColorWithRGB(rgbValue)                                         \
    [UIColor colorWithRed:((float) ((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((float) ((rgbValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((float) (rgbValue & 0xFF)) / 255.0             \
                    alpha:1.0]

#define kSTColorWithRGBA(rgbValue, a)                                     \
    [UIColor colorWithRed:((float) ((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((float) ((rgbValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((float) (rgbValue & 0xFF)) / 255.0             \
                    alpha:a]

#define kSTScreenWidth [UIScreen mainScreen].bounds.size.width
#define kSTScreenHeight [UIScreen mainScreen].bounds.size.height

#define KStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define KNavigationBarHeight 44.0

#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#endif /* STLivenessCommon_h */
