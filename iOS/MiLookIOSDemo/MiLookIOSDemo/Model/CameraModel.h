//
//  StartCameraModel.h
//  MiLookSDKDemo
//
//  Created by 侯 银博 on 2016/11/15.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//

@import Foundation;
// core
#import "JSONModel.h"
#import "JSONModelError.h"

// transformations
#import "JSONValueTransformer.h"
#import "JSONKeyMapper.h"

// networking (deprecated)
#import "JSONHTTPClient.h"
#import "JSONModel+networking.h"
#import "JSONAPI.h"


@interface CameraModel : JSONModel
@property (nonatomic) int cameraID;
@property (nonatomic) int fps;
@property (nonatomic) bool flash;
@property (nonatomic) bool sound;
@property (nonatomic) NSString* previewSize;
@property (nonatomic) NSString* orientation;


@end
