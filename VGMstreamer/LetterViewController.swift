//
//  LetterViewController.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import UIKit

class LetterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let kFavoriteSongs = "My Favorite Songs"
    let kAlbumUrl = "http://downloads.khinsider.com/game-soundtracks/browse/"
    var pickerData: [String] = []
    var currentLatter = ""

    @IBOutlet weak var letterPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let aScalars = "A".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value

        pickerData = (0..<26).map {
            i in String(UnicodeScalar(aCode + i))
        }
        pickerData.insert("#", atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentLatter = pickerData[row]
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "albumListSegue" {
            let albumListTableVC = segue.destinationViewController as AlbumListTableViewController
            albumListTableVC.letterUrl = kAlbumUrl + currentLatter
        } else if segue.identifier == "songListSegue" {
            let songListTableVC = segue.destinationViewController as SongListViewController
            songListTableVC.albumUrl = ""
            songListTableVC.title = kFavoriteSongs
            songListTableVC.songListType = .FavoriteSong
            songListTableVC.songItems = DataController.requestDataItems("1", dataType: .PickSong, sortType: .AlbumName)
        }
    }

    @IBAction func favoriteSongTapped(sender: UIButton) {
        self.performSegueWithIdentifier("songListSegue", sender: nil)
    }
    
    @IBAction func favoriteAlbumTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("favoriteAlbumSegue", sender: nil)
    }
    
    @IBAction func checkAlbumTapped(sender: UIButton) {
        self.performSegueWithIdentifier("albumListSegue", sender: nil)
    }
}
