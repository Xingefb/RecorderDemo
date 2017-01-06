//
//  PermissionsTools.m
//  RecorderAndPlayerDemo
//
//  Created by Dzy on 06/01/2017.
//  Copyright © 2017 Dzy. All rights reserved.
//

#import "PermissionsTools.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>

@implementation PermissionsTools

#pragma mark 录音 话筒授权
+ (BOOL)isAudioAllow
{
    __block BOOL bCanRecord = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            bCanRecord = granted;
        }];
    }
    
    return bCanRecord;
}

#pragma mark 相机授权
+ (BOOL)isCameraAllow {

    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized){
        return YES;
    }else {
        return NO;
    }

}

#pragma mark 相册授权
+ (BOOL)isPhotoAllow {

    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] == NSOrderedAscending) {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        
        if(authStatus == ALAuthorizationStatusAuthorized){
            return YES;
        }else {
            return NO;
        }
    }else {
        
        PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
        
        if(photoAuthStatus == PHAuthorizationStatusAuthorized){
            return YES;
        }else {
            return NO;
        }
    }

}

#pragma mark 位置授权
+ (BOOL)isLocationAllow {

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        return NO;
    }else {
        return YES;
    }

}

@end
