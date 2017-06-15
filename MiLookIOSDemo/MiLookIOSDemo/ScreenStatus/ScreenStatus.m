//
//  ScreenStatus.m
//  MiLookIOSDemo
//
//  Created by 侯 银博 on 2016/12/26.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//


#import "ScreenStatus.h"

#define INVERVAL (1.0/15.0)
#define THRESHOLD (0.5)

@interface ScreenStatus()

@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation ScreenStatus

#pragma mark - Lifecycle

- (id)init {
    if ( self = [super init]) {
	}
	return self;
}

- (void)dealloc {
	[self stop];
}

- (void)start {
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = INVERVAL;
    }
    
    __weak typeof(self)weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [weakSelf accelerometer:accelerometerData];
    }];
}

- (void)stop {
    if (self.motionManager.accelerometerActive) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

#pragma mark - UIAccelerometerDelegate

- (void)accelerometer:(CMAccelerometerData *)accelerometerData {
	force_.x = accelerometerData.acceleration.x;
	force_.y = accelerometerData.acceleration.y;
	force_.z = accelerometerData.acceleration.z;
}

#pragma mark - Instance method

- (BOOL)isScreenLock {
    
	if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        
		FORCE portrait;
		portrait.x = 0.0;
		portrait.y = -1.0;
		portrait.z = 0.0;
		
		float diff = sqrt( (portrait.x-force_.x)*(portrait.x-force_.x)
						  + (portrait.y-force_.y)*(portrait.y-force_.y)
						  + (portrait.z-force_.z)*(portrait.z-force_.z) );
		if ( diff > THRESHOLD ) {
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)isPortrait {
    return UIDeviceOrientationIsPortrait([self physicalOrientation]);
}

- (BOOL)isLandscape {
    return UIDeviceOrientationIsLandscape([self physicalOrientation]);
}

- (UIDeviceOrientation)physicalOrientation {
    
	FORCE orient[10];
	
	orient[UIDeviceOrientationPortrait].x = 0.0;
	orient[UIDeviceOrientationPortrait].y = -1.0;
	orient[UIDeviceOrientationPortrait].z = 0.0;
	
	orient[UIDeviceOrientationPortraitUpsideDown].x = 0.0;
	orient[UIDeviceOrientationPortraitUpsideDown].y = 1.0;
	orient[UIDeviceOrientationPortraitUpsideDown].z = 0.0;

	orient[UIDeviceOrientationLandscapeLeft].x = -1.0;
	orient[UIDeviceOrientationLandscapeLeft].y = 0.0;
	orient[UIDeviceOrientationLandscapeLeft].z = 0.0;

	orient[UIDeviceOrientationLandscapeRight].x = 1.0;
	orient[UIDeviceOrientationLandscapeRight].y = 0.0;
	orient[UIDeviceOrientationLandscapeRight].z = 0.0;
	
	orient[UIDeviceOrientationFaceUp].x = 0.0;
	orient[UIDeviceOrientationFaceUp].y = 0.0;
	orient[UIDeviceOrientationFaceUp].z = -1.0;
	
	orient[UIDeviceOrientationFaceDown].x = 0.0;
	orient[UIDeviceOrientationFaceDown].y = 0.0;
	orient[UIDeviceOrientationFaceDown].z = 1.0;
	
	for(int i = UIDeviceOrientationPortrait; i <= UIDeviceOrientationFaceDown; i++)	{
		float diff = sqrt((orient[i].x-force_.x)*(orient[i].x-force_.x) 
						  + (orient[i].y-force_.y)*(orient[i].y-force_.y)
						  + (orient[i].z-force_.z)*(orient[i].z-force_.z) );
		if ( diff < THRESHOLD ) {
			return i;
		}
	}
	
	return UIDeviceOrientationUnknown;	
}

#pragma mark - Class method

+ (UIDeviceOrientation)orientation:(CMAccelerometerData *)accelerometerData {
	FORCE orient[10];
    
	orient[UIDeviceOrientationPortrait].x = 0.0;
	orient[UIDeviceOrientationPortrait].y = -1.0;
	orient[UIDeviceOrientationPortrait].z = 0.0;
	
	orient[UIDeviceOrientationPortraitUpsideDown].x = 0.0;
	orient[UIDeviceOrientationPortraitUpsideDown].y = 1.0;
	orient[UIDeviceOrientationPortraitUpsideDown].z = 0.0;
    
	orient[UIDeviceOrientationLandscapeLeft].x = -1.0;
	orient[UIDeviceOrientationLandscapeLeft].y = 0.0;
	orient[UIDeviceOrientationLandscapeLeft].z = 0.0;
    
	orient[UIDeviceOrientationLandscapeRight].x = 1.0;
	orient[UIDeviceOrientationLandscapeRight].y = 0.0;
	orient[UIDeviceOrientationLandscapeRight].z = 0.0;
	
	orient[UIDeviceOrientationFaceUp].x = 0.0;
	orient[UIDeviceOrientationFaceUp].y = 0.0;
	orient[UIDeviceOrientationFaceUp].z = -1.0;
	
	orient[UIDeviceOrientationFaceDown].x = 0.0;
	orient[UIDeviceOrientationFaceDown].y = 0.0;
	orient[UIDeviceOrientationFaceDown].z = 1.0;
    
    CMAcceleration acceleration = accelerometerData.acceleration;
	
	for(int i = UIDeviceOrientationPortrait; i <= UIDeviceOrientationFaceDown; i++) {
		float diff = sqrt((orient[i].x-acceleration.x)*(orient[i].x-acceleration.x)
						  + (orient[i].y-acceleration.y)*(orient[i].y-acceleration.y)
						  + (orient[i].z-acceleration.z)*(orient[i].z-acceleration.z) );
		if (diff < THRESHOLD) {
			return i;
		}
	}
	
	return UIDeviceOrientationUnknown;	
}

+ (BOOL)orientationIsPortrait:(CMMotionManager *)motionManager {
    return UIDeviceOrientationIsPortrait([ScreenStatus orientation:motionManager.accelerometerData]);
}

+ (BOOL)orientationIsLandscape:(CMMotionManager *)motionManager {
    return UIDeviceOrientationIsLandscape([ScreenStatus orientation:motionManager.accelerometerData]);
}

@end
