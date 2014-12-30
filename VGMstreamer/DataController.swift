//
//  DataController.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let kModelName = "DataModel"

enum DataModelType {
    case AlbumName
    case AlbumLink
    case SongName
    case SongLink
    case PickAlbum
    case PickSong
}

class DataController {
    
    class func updateSongFavorite (songName: String, albumName: String, favorite: NSNumber) {
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        var requestForDataItem = NSFetchRequest(entityName: kModelName)
        let albumPredicates = NSPredicate(format: "albumName = %@", albumName)
        let songPredicates = NSPredicate(format: "songName = %@", songName)
        let compoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([albumPredicates!, songPredicates!])
        requestForDataItem.predicate = compoundPredicate
        var error: NSError?
        var matchedDataModelArray = managedObjectContext?.executeFetchRequest(requestForDataItem, error: &error) as [DataModel]
        
        let entityDescription = NSEntityDescription.entityForName(kModelName, inManagedObjectContext: managedObjectContext!)
        
        let matchedDataModelCount = matchedDataModelArray.count
        
        for idx in 0..<matchedDataModelArray.count {
            matchedDataModelArray[idx].pickSong = favorite
        }
        appDelegate.saveContext()
    }
    
    class func updateAlbumFavorite (albumName: String, favorite: NSNumber) {
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        var requestForDataItem = NSFetchRequest(entityName: kModelName)
        let predicate = NSPredicate(format: "albumName = %@", albumName) // predicate is like a search criteria
        requestForDataItem.predicate = predicate
        var error: NSError?
        var matchedDataModelArray = managedObjectContext?.executeFetchRequest(requestForDataItem, error: &error) as [DataModel]
        
        let entityDescription = NSEntityDescription.entityForName(kModelName, inManagedObjectContext: managedObjectContext!)
        
        let matchedDataModelCount = matchedDataModelArray.count
        
        for idx in 0..<matchedDataModelArray.count {
            matchedDataModelArray[idx].pickAlbum = favorite
        }
        appDelegate.saveContext()
    }
    
    class func updateSongList (songData: [(link: String, name: String)], albumUrl: String, albumName: String, pickAlbum: NSNumber) {
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        var favoriteSong: [String] = []
        var requestForDataItem = NSFetchRequest(entityName: kModelName)
        let predicate = NSPredicate(format: "albumName = %@", albumName) // predicate is like a search criteria
        requestForDataItem.predicate = predicate
        var error: NSError?
        var matchedDataModelArray = managedObjectContext?.executeFetchRequest(requestForDataItem, error: &error) as [DataModel]
        
        let entityDescription = NSEntityDescription.entityForName(kModelName, inManagedObjectContext: managedObjectContext!)
        
        let matchedDataModelCount = matchedDataModelArray.count
        if matchedDataModelArray.count != 0 {
            for idx in 0..<matchedDataModelCount {
                if matchedDataModelArray[idx].pickSong == 1 {
                    favoriteSong.append(matchedDataModelArray[idx].songName)
                }
                managedObjectContext?.deleteObject(matchedDataModelArray[idx] as NSManagedObject)
            }
            matchedDataModelArray.removeAll(keepCapacity: true)
        }
        
        for song in songData {
            var dataModel = DataModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
            dataModel.pickSong = 0
            for favorite in favoriteSong {
                if song.1 == favorite {
                    dataModel.pickSong = 1
                    break
                }
            }
            dataModel.pickAlbum = pickAlbum
            dataModel.albumLink = albumUrl
            dataModel.albumName = albumName
            dataModel.songLink = song.link
            dataModel.songName = song.name
        }
        appDelegate.saveContext()
    }
    
    class func requestDataItems (pattern: String, dataType: DataModelType, sortType: DataModelType = .SongName ) -> [DataModel] {
        let fetchRequest = NSFetchRequest(entityName: kModelName)
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        
        var predicate = NSPredicate()
        
        switch dataType {
        case .AlbumLink:
            predicate = NSPredicate(format: "albumLink = %@", pattern)! // predicate is like a search criteria
        case .AlbumName:
            predicate = NSPredicate(format: "albumName = %@", pattern)! // predicate is like a search criteria
        case .SongLink:
            predicate = NSPredicate(format: "songLink = %@", pattern)! // predicate is like a search criteria
        case .SongName:
            predicate = NSPredicate(format: "songName = %@", pattern)! // predicate is like a search criteria
        case .PickAlbum:
            predicate = NSPredicate(format: "pickAlbum = %@", pattern)! // predicate is like a search criteria
        case .PickSong:
            predicate = NSPredicate(format: "pickSong = %@", pattern)! // predicate is like a search criteria
        }
        
        var requestForDataItem = NSFetchRequest(entityName: kModelName)
        requestForDataItem.predicate = predicate
        var error: NSError?
        var matchedDataModelArray = managedObjectContext?.executeFetchRequest(requestForDataItem, error: &error) as [DataModel]
        
        matchedDataModelArray.sort { (this, that) -> Bool in
            switch sortType {
            case .AlbumLink:
                return this.albumLink < that.albumLink
            case .AlbumName:
                return this.albumName < that.albumName
            case .SongLink:
                return this.songLink < that.songLink
            case .SongName:
                return this.songName < that.songName
            case .PickAlbum:
                return this.pickAlbum.integerValue < that.pickAlbum.integerValue
            case .PickSong:
                return this.pickSong.integerValue < that.pickSong.integerValue
            }
        }
        return matchedDataModelArray
    }
}
