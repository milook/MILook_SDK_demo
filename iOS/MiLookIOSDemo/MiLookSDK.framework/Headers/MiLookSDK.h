//
//  MiLookSDK.h
//  MiLookSDK
//
//  Created by 侯 银博 on 2016/11/9.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MiLookSDKDelegate.h"

@interface MiLookSDK : NSObject

/**
 * NSObject
 */
@property (nonatomic, assign) id<MiLookSDKDelegate> delegate;
@property (nonatomic) int cameraID;
@property (nonatomic) BOOL flashStatus;
/***
 *initialization SDK
 */
+(id)shareMiLookSDK;

/***
 *initialization SDK parameter
 */
- (bool) InitSDK:(NSString*) licenseKey
    withRootPath:(NSString*) propRootPath
   withModelPath:(NSString*) trackModelPath
     withMaxFace:(int) trackMaxFace;

/***
 *Start Camera
 */
-(void) StartCamera:(NSString*) jsonParam;

/***
 *OrientationChange
 */
-(void) OrientationChange:(NSString*)ori;

/**
 * display
 */
-(void) display:(BOOL)isdisplay;

/**
 * Turn off the flash
 */
- (void)turnOffFlash;

/**
 * Turn on the flash
 */
- (void)turnOnFlash;

/***
 *StartPreview
 *@param[in] frame frame parameter
 */
-(UIView*) StartPreview:(CGRect)frame;

/***
 *Switch the camera
 */
-(void) SwitchCamera;

/***
 *Set the camera parameters
 *@param[in] jsonParam json
 */
-(void) SetCameraParam:(NSString*) jsonParam;

/***
 *Stop Camera
 */
-(void) StopCamera;

/***
 *Stop Preview
 */
-(void) StopPreview;

/***
 *Set the AR parameters
 *@param[in] jsonParam json RGBA32 NV21
 */
-(void) SetDecoration:(NSString*) jsonParam;

/***
 *clear AR effect
 */
-(void) SetDecorationClear;

/***
 *Set face track delegate
 */
-(void) SetTrackDelegate:(id<TrackDelegate>) delegate;

/***
 *Set camera delegate
 */
-(void) SetCamDelegate:(id<CameraDelegate>) delegate;

/**
 *
 *Enter the camera's original image
 *@param[in] pixelBuffer parameter
 */
-(void) ProcessFrame:(CVPixelBufferRef)pixelBuffer
withPresentationTime:(CMTime) timestamp
      withVideoWidth:(GLfloat) camVideoWidth
     withVideoHeight:(GLfloat) camVideoHeight
     withOrientation:(NSString*) camOrientation
        withCameraID:(int)camID;

@end


