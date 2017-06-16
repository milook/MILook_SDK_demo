//
//  DispatchQueue.swift
//  MiLookSwiftDemo
//
//  Created by 侯 银博 on 2017/5/19.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//

import Foundation
import UIKit
//dispatch_once 拓展
public extension DispatchQueue{
    public static var onceTracker = [String]()
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}
