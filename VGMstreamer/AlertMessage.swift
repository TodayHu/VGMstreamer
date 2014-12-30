//
//  AlertMessage.swift
//  VGMstreamer
//
//  Created by tsunghao on 2014/12/31.
//  Copyright (c) 2014年 MistyDay. All rights reserved.
//

import Foundation
import UIKit

class AlertMessage {
    private var activityIndicator = UIActivityIndicatorView()
    private var alert = UIAlertController()

    class func showAlert (title: String = "Warning", message: String = "Error occur!", viewController: UIViewController) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showWaitingAlert (title: String = "Processing", message: String = "Retriving data...", viewController: UIViewController) {
        self.alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)

        self.activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.activityIndicator.center = CGPointMake(15, 15)
        
        self.alert.view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        viewController.presentViewController(self.alert, animated: true, completion: nil)
    }
    
    func hideWaitingAlert () {
        self.alert.dismissViewControllerAnimated(true, completion: nil)
    }
}
