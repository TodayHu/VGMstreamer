//
//  WebContent.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import Foundation

class WebContent {
    class func getWebContent(url: String) -> String {
        var webContent: String = ""
        var finished: Bool = false
        var errorHappen: Bool = false
        let url = NSURL(string: url)
        
        if url != nil {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)!
                    webContent = (stringData as String)
                } else {
                    println((error as NSError).localizedDescription)
                    errorHappen = true
                }
                finished = true
            })
            task.resume()
            while !finished && !errorHappen {
            }
        }
        return webContent
    }
}
