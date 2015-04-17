//
//  StringHandle.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import Foundation

class StringHandle {
    class func subStringWithRegx(string: String, pattern: String) -> (string: String?, range: Range<String.Index>?) {
        var range: Range? = string.rangeOfString(pattern, options: .RegularExpressionSearch)

        if range != nil {
            var subString = string.substringWithRange(range!)
            return (subString, range)
        }
        return (nil, nil)
    }
    
    class func subStringWithString(string: String, pattern: String) -> String? {
        if let range = string.rangeOfString(pattern) {
            return string.substringWithRange(range)
        }
        return nil
    }
    
    class func substringToIndex(string: String, index: Int) -> String {
        return string.substringToIndex(advance(string.startIndex, index))
    }
    
    class func substringFromIndex(string: String, index: Int) -> String {
        return string.self.substringFromIndex(advance(string.startIndex, index))
    }
    
    class func substringWithRange(string: String, start: Int, end: Int) -> String {
        let start = advance(string.startIndex, start)
        let end = advance(string.startIndex, end)
        return string.substringWithRange(start..<end)
    }

    class func reverseString(string: String) -> String {
        var reversed = ""
        for char in reverse(string) {
            reversed += "\(char)"
        }
        return reversed
    }
    
    class func replaceByRegex(string: String, oldPattern: String, newPattern: String) -> String {
        let regex = NSRegularExpression(pattern: oldPattern, options: nil, error: nil)
        var strMutable: NSMutableString = ""
        strMutable.setString(string)
        regex?.replaceMatchesInString(strMutable, options: nil, range: NSMakeRange(0, count(string)), withTemplate: newPattern)
        return (strMutable as String)
    }
}
