//
//  SongTableViewCell.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import UIKit
import CoreData

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var pickSongButton: UIButton!
    @IBOutlet weak var checkSongButton: UIButton!
    
    @IBOutlet weak var songLabel: UILabel!
    var albumTitle = ""
    var favorite = false
//    var check = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func favoriteTapped(sender: UIButton) {
        if favorite {
            DataController.updateSongFavorite(songLabel.text!, albumName: albumTitle, favorite: 0)
            sender.setBackgroundImage(UIImage(named: "heart.png"), forState: UIControlState.Normal )
        } else {
            DataController.updateSongFavorite(songLabel.text!, albumName: albumTitle, favorite: 1)
            sender.setBackgroundImage(UIImage(named: "heartFill.png"), forState: UIControlState.Normal )
        }
        favorite = !favorite
    }
}
