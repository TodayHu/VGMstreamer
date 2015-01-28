//
//  WatchKitInfo.swift
//  VGMstreamer
//
//  Created by tsunghao on 2015/1/28.
//  Copyright (c) 2015年 MistyDay. All rights reserved.
//

import Foundation

let key = "FunctionRequestKey"

class WatchKitInfo {
    var replyDictionary: ([NSObject : AnyObject]!) -> Void
    var playerRequest: String?
    
    init (playerDict: [NSObject : AnyObject], replyDict: ([NSObject : AnyObject]!) -> Void) {
        
        if let player = playerDict as? [String : String] {
            playerRequest = player[key]
        } else {
            println("No Information Error")
        }
        replyDictionary = replyDict
    }
}
