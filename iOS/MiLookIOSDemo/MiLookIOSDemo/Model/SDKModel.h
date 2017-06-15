//
//  SDKModel.h
//  MiLookIOSDemo
//
//  Created by 侯 银博 on 2017/3/21.
//  Copyright © 2017年 houyinbo. All rights reserved.
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

@interface SDKModel : JSONModel

@property (nonatomic) NSString* rootPath;
@property (nonatomic) NSString* modelPath;
@property (nonatomic) NSString* licenseKey;
@property (nonatomic) int maxFace;

@end
