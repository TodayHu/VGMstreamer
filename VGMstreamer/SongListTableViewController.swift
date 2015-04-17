//
//  SongListTableViewController.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

// enum for SongList View type (There are 3 entries lead to this Controller)
enum SongListType {
    case GeneralSong
    case FavoriteAlbum
    case FavoriteSong
}
// enum for Shuffle mode
enum ShuffleMode {
    case None
    case Shuffle
    
    func description() -> String {
        switch self {
        case .None:
            return "No Shuffle"
        case .Shuffle:
            return "Shuffle"
        }
    }
}
// enum for Playback mode
enum PlaybackMode {
    case Single
    case RepeatSingle
    case RepeatAlbum
    
    func description() -> String {
        switch self {
        case .Single:
            return "Single"
        case .RepeatSingle:
            return "Repeat one"
        case .RepeatAlbum:
            return "Repeat all"
        }
    }
}
// enum for Section/row update. Playback means play automatically
enum SectionRowUpdate {
    case Next
    case Previous
    case Playback
    
    func description() -> String {
        switch self {
        case .Next:
            return "Next"
        case .Previous:
            return "Previous"
        case .Playback:
            return "Playback"
        }
    }
}

class SongListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var albumUrl: String = ""
    var songItems: [DataModel] = []
    var favoriteSongItems: [[DataModel]] = [[]]
    let kSongWaitingSeconds: NSTimeInterval = 3
    var manualPaused = false
    var refresher: UIRefreshControl!
    var songListType: SongListType = .GeneralSong
    var playBackMode: PlaybackMode = .RepeatAlbum
    var shuffleMode: ShuffleMode = .None

    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet var songTableView: UITableView!
    
    var currentSection = -1
    var currentRow = -1
    var currentSongName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if self.songListType == .GeneralSong {
            songItems = DataController.requestDataItems(self.title!, dataType: .AlbumName)
  
            if self.songItems.isEmpty {
                let parseQueue: dispatch_queue_t = dispatch_queue_create("parseSong queue", nil)
                var alert = AlertMessage()
                
                alert.showWaitingAlert(viewController: self)
                dispatch_async(parseQueue, { () -> Void in
                    self.parseSongList()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.songTableView.reloadData()
                        alert.hideWaitingAlert()
                    })
                })
            }
            var organizeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: Selector("saveFavoriteAlbum"))
            
            self.navigationItem.rightBarButtonItem = organizeButton
        } else if self.songListType == .FavoriteSong {
            self.reGroupFavoriteSong()
        }
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.songTableView.addSubview(refresher)

        // Notification for WatchKit event
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleWatchKitRequest:"), name: "WatchKitDidMakeRequest", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if songListType == .FavoriteSong {
            return favoriteSongItems.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let rowToSelect: NSIndexPath = NSIndexPath(forRow: currentRow, inSection: section)
        if self.songListType == .FavoriteSong {
            return favoriteSongItems[section][0].albumName
        } else {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if songListType == .FavoriteSong {
            return favoriteSongItems[section].count
        } else {
            return songItems.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SongTableViewCell! = tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath: indexPath) as! SongTableViewCell
        
        // Configure the cell...
        if songListType == .FavoriteSong {
            cell.songLabel.text = favoriteSongItems[indexPath.section][indexPath.row].songName
            cell.albumTitle = favoriteSongItems[indexPath.section][indexPath.row].albumName
        } else {
            cell.songLabel.text = songItems[indexPath.row].songName
            cell.albumTitle = self.title!
        }
        
        if songItems[indexPath.row].pickSong == 1 {
            cell.pickSongButton.setBackgroundImage(UIImage(named: "heartFill.png"), forState: UIControlState.Normal )
            cell.favorite = true
        } else {
            cell.pickSongButton.setBackgroundImage(UIImage(named: "heart.png"), forState: UIControlState.Normal )
            cell.favorite = false
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if songListType == .FavoriteSong {
            mediaPlayer.contentURL = NSURL(string: favoriteSongItems[indexPath.section][indexPath.row].songLink)
            currentSongName = favoriteSongItems[indexPath.section][indexPath.row].songName
        } else {
            mediaPlayer.contentURL = NSURL(string: songItems[indexPath.row].songLink)
            currentSongName = songItems[indexPath.row].songName
        }
        currentSection = indexPath.section
        currentRow = indexPath.row
        self.startMediaPlayer()        
    }
    
    // MARK: - Helper function
    func saveFavoriteAlbum() {
        DataController.updateAlbumFavorite(self.title!, favorite: 1)
        AlertMessage.showAlert(title: "Success", message: "Add album into favorite!", viewController: self)
    }
    
    func pullToRefresh() {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.refresher.beginRefreshing()
        
        self.reloadSongList()
        
        self.refresher.endRefreshing()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func reloadSongList() {
        self.stopMediaPlayer()
        if songListType == .FavoriteSong {
            self.songItems = DataController.requestDataItems("1", dataType: .PickSong, sortType: .AlbumName)
            self.reGroupFavoriteSong()
        } else {
            self.parseSongList()
        }
        
        if self.songItems.isEmpty {
            self.playButton.enabled = false
            self.stopButton.enabled = false
        } else {
            self.playButton.enabled = true
            self.stopButton.enabled = true
        }
        songTableView.reloadData()
    }
    
    @IBAction func playButtonTapped(sender: UIBarButtonItem) {
        if !songItems.isEmpty {
            if mediaPlayer.playbackState == MPMoviePlaybackState.Playing {
                self.stopMediaPlayer(type: MPMoviePlaybackState.Paused)

            } else { //pause or stop
                if currentSection == -1 {
                    currentSection = 0
                }
                if currentRow == -1 {
                    currentRow = 0
                    self.selectTableItem()
                } else {
                    self.startMediaPlayer()
                }
            }
        }
    }
    
    @IBAction func stopButtonTapped(sender: UIBarButtonItem) {
        if !songItems.isEmpty {
            self.stopMediaPlayer()
        }
    }
    
    @IBAction func shuffleButtonTapped(sender: UIBarButtonItem) {
        switch shuffleMode {
            case .None:
                shuffleMode = .Shuffle
            case .Shuffle:
                shuffleMode = .None
        }
        sender.title = shuffleMode.description()
    }
    
    @IBAction func repeatButtonTapped(sender: UIBarButtonItem) {
        switch playBackMode {
            case .Single:
                mediaPlayer.repeatMode = MPMovieRepeatMode.None
                playBackMode = .RepeatSingle
            case .RepeatSingle:
                mediaPlayer.repeatMode = MPMovieRepeatMode.One
                playBackMode = .RepeatAlbum
            case .RepeatAlbum:
                mediaPlayer.repeatMode = MPMovieRepeatMode.None
                playBackMode = .Single
        }
        sender.title = playBackMode.description()
    }
    
    func stopMediaPlayer(type: MPMoviePlaybackState = .Stopped) {
        if type == .Paused {
            mediaPlayer.pause()
        } else if type == .Stopped {
            mediaPlayer.stop()
        }
        globalTimer.invalidate()
        self.playButton?.title = "Play"
        self.manualPaused = true
        println("stopMediaPlayer stop timer!")
    }
    
    func startMediaPlayer() {
        if mediaPlayer.playbackState != .Paused || !manualPaused {
            mediaPlayer.stop()
        }
        globalTimer.invalidate()
        globalTimer = NSTimer.scheduledTimerWithTimeInterval(self.kSongWaitingSeconds, target: self, selector: Selector("selectSong"), userInfo: nil, repeats: true)
        mediaPlayer.play()
        self.playButton.title = "Pause"
        self.manualPaused = false
        println("startMediaPlayer create timer = \(globalTimer)")
    }
    
    func selectTableItem() {
        let rowToSelect: NSIndexPath = NSIndexPath(forRow: currentRow, inSection: currentSection)
        self.songTableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.tableView(self.songTableView, didSelectRowAtIndexPath: rowToSelect)
    }
    
    func previousSong() {
        self.stopMediaPlayer(type: MPMoviePlaybackState.Stopped)
        self.updateSectionRow(.Previous)
        self.selectTableItem()
    }
    
    func nextSong() {
        self.stopMediaPlayer(type: MPMoviePlaybackState.Stopped)
        self.updateSectionRow(.Next)
        self.selectTableItem()
    }
    
    func updateSectionRow(update: SectionRowUpdate) {
        
        let takeOneStep = { (forward: Bool) -> Void in
            let step = forward ? 1 : -1
            
            if self.shuffleMode == .None {
                self.currentRow += step

                if self.songListType == .FavoriteSong {
                    if (forward && self.currentRow == self.favoriteSongItems[self.currentSection].count) ||
                       (!forward && self.currentRow < 0) {
                        self.currentSection += step

                        if self.currentSection >= 0 {
                            self.currentSection %= self.favoriteSongItems.count
                        } else {
                            self.currentSection = self.favoriteSongItems.count - 1
                        }
                        if forward {
                            self.currentRow = 0
                        }
                    }
                }
                let songItemMax = self.songListType == .FavoriteSong ? self.favoriteSongItems[self.currentSection].count : self.songItems.count
                
                if self.currentRow >= 0 {
                    self.currentRow %= songItemMax
                } else {
                    self.currentRow = songItemMax - 1
                }
            } else {
                if self.songListType == .FavoriteSong {
                    self.currentSection = Int(arc4random_uniform(UInt32(self.favoriteSongItems.count)))
                }
                let songItemMax = self.songListType == .FavoriteSong ? self.favoriteSongItems[self.currentSection].count : self.songItems.count
                self.currentRow = Int(arc4random_uniform(UInt32(songItemMax)))
            }
        }
        
        switch update {
            case .Next:
                fallthrough
            case .Playback:
                takeOneStep(true)
            case .Previous:
                takeOneStep(false)
        }
        println("currentSection = \(currentSection), currentRow = \(currentRow)")
    }
    
    func selectSong() {
        if playBackMode == .RepeatAlbum {
            // last song was ended natuarally
            if mediaPlayer.playbackState == MPMoviePlaybackState.Paused && !manualPaused {
                self.updateSectionRow(.Playback)
                self.selectTableItem()
            }
        } else if playBackMode == .RepeatSingle {
            if mediaPlayer.playbackState != MPMoviePlaybackState.Playing && !manualPaused {
                self.playButton.title = "Play"
            }
        }
        println("selectSong timer = \(globalTimer), currentSection = \(currentSection), currentRow = \(currentRow), playState = \(mediaPlayer.playbackState.rawValue)")
    }
    
    func reGroupFavoriteSong() {
        var albumList: [String] = []
        
        for idx in 0..<songItems.count {
            if idx < songItems.count - 1 {
                if songItems[idx+1].albumName != songItems[idx].albumName {
                    albumList.append(songItems[idx].albumName)
                }
            } else {
                if albumList.isEmpty {
                    albumList.append(songItems[idx].albumName)
                } else {
                    if songItems[idx].albumName != albumList[albumList.count-1] {
                        albumList.append(songItems[idx].albumName)
                    }
                }
            }
        }
        favoriteSongItems.removeAll(keepCapacity: true)
        for album in albumList {
            var ary = filter(songItems, { $0.albumName == album })
            if !ary.isEmpty {
                ary.sort { (this, that) -> Bool in
                    return this.songName < that.songName
                }
                self.favoriteSongItems.append(ary)
            }
        }
    }
 
    func parseSongList() {
        var startTime = NSDate.timeIntervalSinceReferenceDate()
        var webContent = WebContent.getWebContent(albumUrl)

        if webContent == "" {
            AlertMessage.showAlert(message: "Please check network connection!", viewController: self)
            return
        }

/*  Maybe faster
        if webContent != "" {
            let replaceToken = "(.)(.)OGC"
            webContent = StringHandle.replaceByRegex(webContent, oldPattern: "\r\n", newPattern: replaceToken)
            var parsedDataSet = StringHandle.subStringWithRegx(webContent, pattern: "<table align=.*</table>")
            if parsedDataSet.string != nil {
                webContent = StringHandle.replaceByRegex(parsedDataSet.string!, oldPattern: replaceToken, newPattern: "\r\n")
            }
        }
*/
        var handleString = webContent
        var remainStr: String?
        var songData: [(link: String, name: String)] = []
        
        while true {
            var parsedDataSet = StringHandle.subStringWithRegx(handleString, pattern: "http://.*.mp3\">Download")
            if parsedDataSet.string != nil {
                var songLink: String = parsedDataSet.string!
                songLink = StringHandle.substringToIndex(songLink, index: count(songLink) - count("\">Download"))
                var remainRange = Range(start: parsedDataSet.range!.endIndex, end: handleString.endIndex)
                handleString = handleString.substringWithRange(remainRange)

                webContent = WebContent.getWebContent(songLink)
                
                if webContent != "" {
                    parsedDataSet = StringHandle.subStringWithRegx(webContent, pattern: "http://.*.mp3\">Click")
                    if parsedDataSet.string != nil {
                        var songLink = parsedDataSet.string!
                        songLink = StringHandle.substringToIndex(songLink, index: count(songLink) - count("\">Click"))
                        
                        var revSongLink = StringHandle.reverseString(songLink)
                        parsedDataSet = StringHandle.subStringWithRegx(revSongLink, pattern: "/")
                        if parsedDataSet.string != nil {
                            remainRange = Range(start: revSongLink.startIndex, end: parsedDataSet.range!.startIndex)
                            var songName: String = revSongLink.substringWithRange(remainRange)
                            songName = StringHandle.substringWithRange(songName, start: count("3pm."), end: count(songName))
                            songName = StringHandle.reverseString(songName)
                            songData += [(link: songLink, name: songName)]
                        }
                    }
                } else {
                    break
                }
            } else {
                break
            }
        }
        if songItems.isEmpty {
            DataController.updateSongList(songData, albumUrl: albumUrl, albumName: self.title!, pickAlbum: songListType == .FavoriteAlbum ? 1 : 0)
        } else {
            DataController.updateSongList(songData, albumUrl: albumUrl, albumName: self.title!, pickAlbum: songListType == .FavoriteAlbum ? 1 : songItems[0].pickAlbum)
        }
        songItems = DataController.requestDataItems(self.title!, dataType: .AlbumName)

        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = currentTime - startTime
        println("parseSongList = \(Double(elapsedTime))")
    }
    
    // MARK: - WatchKit Notification
    func handleWatchKitRequest(notification: NSNotification) {
        let watchKitInfo = notification.object as? WatchKitInfo
        
        if let requestedAction = watchKitInfo?.playerRequest {
            switch requestedAction {
            case "Play":
                self.playButtonTapped(UIBarButtonItem())
            case "Previous":
                self.previousSong()
            case "Next":
                self.nextSong()
            default:
                println("Should not happend!")
            }
            let currentSongDictionary = ["CurrentSong": currentSongName]
            watchKitInfo?.replyDictionary(currentSongDictionary)
        }
    }
}

// MARK: - TODO list
// Refactor code to indicate current playing status
// Search bar
// Moving row animation
// marguee song name?????
