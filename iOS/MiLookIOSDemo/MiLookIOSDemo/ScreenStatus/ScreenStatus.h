//
//  ScreenStatus.h
//  MiLookIOSDemo
//
//  Created by 侯 银博 on 2016/12/26.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//


#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>

typedef struct FORCE {
	float x;
	float y;
	float z;
} FORCE;

@interface ScreenStatus : NSObject {
	FORCE force_;
}

- (void)start;
- (void)stop;
- (BOOL)isScreenLock;
- (BOOL)isPortrait;
- (BOOL)isLandscape;
- (UIDeviceOrientation)physicalOrientation;

+ (UIDeviceOrientation)orientation:(CMAccelerometerData *)accelerometerData;
+ (BOOL)orientationIsPortrait:(CMMotionManager *)motionManager;
+ (BOOL)orientationIsLandscape:(CMMotionManager *)motionManager;

@property (getter=isScreenLock, readonly) BOOL isScreenLock;
@property (getter=isPortrait, readonly) BOOL isPortrait;
@property (getter=isLandscape, readonly) BOOL isLandscape;
@property (getter=physicalOrientation, readonly) UIDeviceOrientation physicalOrientation;

@end
