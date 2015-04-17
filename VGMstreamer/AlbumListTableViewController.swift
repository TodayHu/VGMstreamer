//
//  AlbumListTableViewController.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import UIKit

class AlbumListTableViewController: UITableViewController {
    
    var letterUrl: String = ""
    var albumLinks: [String] = []
    var albumNames: [String] = []

    var activityindicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var albumTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        let parseQueue: dispatch_queue_t = dispatch_queue_create("parseAlbum queue", nil)
        var alert = AlertMessage()
        
        alert.showWaitingAlert(viewController: self)
        dispatch_async(parseQueue, { () -> Void in
            self.parseAlbumList()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                alert.hideWaitingAlert()
            })
        })
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
        return albumNames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = albumNames[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("songListSegue", sender: albumLinks[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let songListTableVC = segue.destinationViewController as! SongListViewController
        songListTableVC.albumUrl = sender as! String
        var indexPath = self.albumTableView.indexPathForSelectedRow()
        songListTableVC.title = self.albumNames[indexPath!.row]
        songListTableVC.songListType = .GeneralSong
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    func parseAlbumList() {
        var startTime = NSDate.timeIntervalSinceReferenceDate()
        var webContent = WebContent.getWebContent(letterUrl)
        
        if webContent == "" {
            AlertMessage.showAlert(message: "Please check network connection!", viewController: self)
            return
        }
        
        var handleString = webContent
        var remainStr: String?
        
        while true {
            var parsedDataSet = StringHandle.subStringWithRegx(handleString, pattern: "http://.*album.*</a>")
            if parsedDataSet.string != nil {
                var albumLink = parsedDataSet.string!
                let fullString = albumLink
                var fullRange = parsedDataSet.range!
                
                parsedDataSet = StringHandle.subStringWithRegx(fullString, pattern: ">.*<")
                if parsedDataSet.string != nil {
                    var albumName = parsedDataSet.string!
                    albumName = StringHandle.substringWithRange(albumName, start: 1, end: count(albumName) - 1)
                    albumNames.append(albumName)
                }
                
                parsedDataSet = StringHandle.subStringWithRegx(fullString, pattern: ".*\">")
                
                if parsedDataSet.string != nil {
                    albumLink = parsedDataSet.string!
                    albumLink = StringHandle.substringToIndex(albumLink, index: count(albumLink) - count("\">"))
                    albumLinks.append(albumLink)
                    
                    var remainRange = Range(start: fullRange.endIndex, end: handleString.endIndex)
                    handleString = handleString.substringWithRange(remainRange)
                } else {
                    break
                }
            } else {
                break
            }
        }
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = currentTime - startTime
        println("parseAlbumList = \(Double(elapsedTime))")
    }
}
