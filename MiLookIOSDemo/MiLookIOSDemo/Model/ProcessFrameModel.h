//
//  ProcessFrameModel.h
//  MiLookSDKDemo
//
//  Created by 侯 银博 on 2016/11/23.
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


@interface ProcessFrameModel : JSONModel

@property (nonatomic) NSString* previewSize;
@property (nonatomic) int format;
@property (nonatomic) NSString* orientation;
@property (nonatomic) int mirror;
@property (nonatomic) int cameraID;

@end
