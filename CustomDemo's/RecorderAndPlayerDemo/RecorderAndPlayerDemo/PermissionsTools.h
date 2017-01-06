//
//  PermissionsTools.h
//  RecorderAndPlayerDemo
//
//  Created by Dzy on 06/01/2017.
//  Copyright © 2017 Dzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermissionsTools : NSObject


/**
 麦克风权限（录音等）

 @return Audio is can or not allow
 */
+ (BOOL)isAudioAllow;

/**
 相机权限
 
 @return Audio is can or not allow
 */
+ (BOOL)isCameraAllow;

/**
 相册权限

 @return Photo is can or not allow
 */
+ (BOOL)isPhotoAllow;

/**
 位置权限

 @return loacation is can allow
 */
+ (BOOL)isLocationAllow;


@end
