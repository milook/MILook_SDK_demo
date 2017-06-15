//
//  MiLookSDKDelegate.h
//  MiLookSDK
//
//  Created by 侯 银博 on 2016/11/16.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol MiLookSDKDelegate<NSObject>

@optional
-(void) captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
       devicePosition:(AVCaptureDevicePosition)devicePosition
          ofMediaType:(NSString*) mediaType
     videoPixelBuffer:(CVPixelBufferRef) pixelBuffer
 withPresentationTime:(CMTime) timestamp;

@end

@protocol TrackDelegate<NSObject>

@optional
-(void) onFrameResult:(int) result trackData:(float[21]) trackData;

@end

@protocol CameraDelegate<NSObject>

@optional
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
devicePosition:(AVCaptureDevicePosition)devicePosition
          ofMediaType:(NSString*) mediaType;

@end


