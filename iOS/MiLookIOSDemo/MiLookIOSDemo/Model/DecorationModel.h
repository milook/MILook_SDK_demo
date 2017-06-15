//
//  DecorationModel.h
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

@interface BeautifyModel : JSONModel

@property (nonatomic) float level;

@end

@interface FaceDeformModel : JSONModel

@property (nonatomic) float slim;
@property (nonatomic) float bigEye;
@property (nonatomic) float jaw;

@end

@interface PostFilterModel : JSONModel
@property (nonatomic) NSString* type;
@property (nonatomic) NSString* folder;  //图片列表

@end

@interface VideoFilterModel : JSONModel
@property (nonatomic) NSString* type;
@property (nonatomic) NSString* folder;  //图片列表

@end

@protocol CombModel;

@interface CombModel : JSONModel

@property (nonatomic) NSString* type; //类型
@property (nonatomic) NSString* folder;  //图片列表

@end

@interface DecorationModel : JSONModel

@property (nonatomic) BeautifyModel *beautify;

@property (nonatomic) FaceDeformModel *faceDeform;

@property (nonatomic) bool points;

@property (nonatomic) int maxFace;

@property (nonatomic) NSArray<CombModel> *comb;

@property (nonatomic) PostFilterModel *postFilter;

@property (nonatomic) VideoFilterModel *videoFilter;

@end
