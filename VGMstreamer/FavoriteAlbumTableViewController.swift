//
//  FavoriteAlbumTableViewController.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import UIKit

class FavoriteAlbumTableViewController: UITableViewController {

    var dataModels: [DataModel] = []
    var albumLists: [DataModel] = []
    @IBOutlet var favoriteAlbumListView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getFavoriteAlbumList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.albumLists.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteAlbumListCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = albumLists[indexPath.row].albumName

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("songListSegue", sender: albumLists[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let songListTableVC = segue.destinationViewController as! SongListViewController
        var indexPath = self.favoriteAlbumListView.indexPathForSelectedRow()
        songListTableVC.albumUrl = self.albumLists[indexPath!.row].albumLink
        songListTableVC.title = self.albumLists[indexPath!.row].albumName
        songListTableVC.songListType = .FavoriteAlbum
        songListTableVC.songItems = getSongLists(self.albumLists[indexPath!.row].albumName)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            DataController.updateAlbumFavorite(albumLists[indexPath.row].albumName, favorite: 0)
            self.getFavoriteAlbumList()
            AlertMessage.showAlert(title: "Success", message: "Favorite album was deleted", viewController: self)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func getSongLists(albumName: String) -> [DataModel] {
        var songLists: [DataModel] = []
        
        songLists = filter(dataModels, { $0.albumName == albumName })
        songLists.sort { (this, that) -> Bool in
            return this.songName < that.songName
        }
        return songLists
    }
    
    func getFavoriteSongList() -> [DataModel] {
        return DataController.requestDataItems("1", dataType: .PickSong, sortType: .AlbumName)
    }
    
    func getFavoriteAlbumList() {
        albumLists.removeAll(keepCapacity: true)
        dataModels.removeAll(keepCapacity: true)
        
        self.dataModels = DataController.requestDataItems("1", dataType: .PickAlbum, sortType: .AlbumName)
        
        for idx in 0..<dataModels.count {
            if idx < dataModels.count - 1 {
                if dataModels[idx+1].albumName != dataModels[idx].albumName {
                    albumLists.append(dataModels[idx])
                }
            } else {
                if albumLists.isEmpty {
                    albumLists.append(dataModels[idx])
                } else {
                    if dataModels[idx].albumName != albumLists[albumLists.count-1].albumName {
                        albumLists.append(dataModels[idx])
                    }
                }
            }
        }
        favoriteAlbumListView.reloadData()
    }
}
