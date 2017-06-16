//
//  DecorationModel.swift
//  MiLookSwiftDemo
//
//  Created by 侯 银博 on 2017/4/19.
//  Copyright © 2017年 houyinbo. All rights reserved.
//

import Foundation
import HandyJSON

struct BeautifyModel: HandyJSON {
    var level: Float?
}

struct FaceDeformModel: HandyJSON {
    var slim: Float?
    var bigEye: Float?
    var jaw: Float?
}

struct CombModel: HandyJSON {
    var type: String?
    var folder: String?
}

struct PostFilterModel: HandyJSON {
    var type: String?
    var folder: String?
}

struct VideoFilterModel: HandyJSON {
    var type: String?
    var folder: String?
}

class DecorationModel: HandyJSON {
    var beautify:BeautifyModel = BeautifyModel();
    
    var faceDeform:FaceDeformModel = FaceDeformModel();
    
    var points:Bool?;

    var maxFace:Int?;

    var comb:Array<CombModel> = Array<CombModel>();
    
    var postFilter:PostFilterModel = PostFilterModel();
   
    var videoFilter:VideoFilterModel = VideoFilterModel();

    required init() {}
}
