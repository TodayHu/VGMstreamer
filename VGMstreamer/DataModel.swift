//
//  DataModel.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import Foundation
import CoreData

@objc (DataModel)
class DataModel: NSManagedObject {

    @NSManaged var albumLink: String
    @NSManaged var albumName: String
    @NSManaged var pickAlbum: NSNumber
    @NSManaged var songLink: String
    @NSManaged var songName: String
    @NSManaged var pickSong: NSNumber

}
