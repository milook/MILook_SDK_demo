//
//  CameraModel.swift
//  MiLookSwiftDemo
//
//  Created by 侯 银博 on 2017/4/19.
//  Copyright © 2017年 houyinbo. All rights reserved.
//

import Foundation
import HandyJSON

class CameraModel: HandyJSON {
    var cameraID: Int?
    var fps: Int?
    var flash:Bool?
    var sound:Bool?
    var previewSize: String?
    var orientation: String?
    required init() {}
}
