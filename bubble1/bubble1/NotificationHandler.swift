//
//  NotificationHandler.swift
//  bubble1
//
//  Created by Sumanth on 2/2/18.
//  Copyright © 2018 sumanths. All rights reserved.
//

import Foundation
import OneSignal
import SwiftyJSON

class NotificationHandler {
    // Singleton.
    private static var sharedInstance:NotificationHandler = {
        return NotificationHandler()
    }()
    
    private init() {
    }
    
    public static func shared() -> NotificationHandler {
        return sharedInstance
    }
    
    var notificationDelegate: NotificationDelegate?
    
    public func setDelegate(_ delegate: NotificationDelegate) {
        self.notificationDelegate = delegate
    }
    
    public func handle(_ notification: OSNotification) -> Void {
        let additionalData = JSON(notification.payload.additionalData)
        let type = additionalData["Type"]
        print(type)
        if type == "ConfirmTrip" {
            self.notificationDelegate?.rideAccepted(data: additionalData)
        }
    }
}

protocol NotificationDelegate {
    func rideAccepted(data: JSON) -> Void
}
