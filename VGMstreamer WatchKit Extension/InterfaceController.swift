//
//  InterfaceController.swift
//  VGMstreamer WatchKit Extension
//
//  Created by tsunghao on 2015/1/28.
//  Copyright (c) 2015年 MistyDay. All rights reserved.
//

import WatchKit
import Foundation
import UIKit

let key = "FunctionRequestKey"
class InterfaceController: WKInterfaceController {

    @IBOutlet weak var songName: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - Helper function
    @IBAction func previousSong() {
        var info = [key : "Previous"]
        
        WKInterfaceController.openParentApplication(info, reply: { (reply, error) -> Void in
            println("[In WatchKit@InterfaceController] reply: \(reply), error: \(error)")
            if reply != nil {
                self.updateLabel(reply as! [String : String])
            }
        })
    }

    @IBAction func nextSong() {
        var info = [key : "Next"]
        
        WKInterfaceController.openParentApplication(info, reply: { (reply, error) -> Void in
            println("[In WatchKit@InterfaceController] reply: \(reply), error: \(error)")
            if reply != nil {
                self.updateLabel(reply as! [String : String])
            }
        })
    }
    
    @IBAction func playSong() {
        var info = [key : "Play"]
        
        WKInterfaceController.openParentApplication(info, reply: { (reply, error) -> Void in
            println("[In WatchKit@InterfaceController] reply: \(reply), error: \(error)")
            if reply != nil {
                self.updateLabel(reply as! [String : String])
            }
        })
    }
    
    // MARK: - Helper functions
    func updateLabel (songDictionary: [String : String]) {
        let songName = songDictionary["CurrentSong"]
        self.songName.setText(songName)
    }
}
