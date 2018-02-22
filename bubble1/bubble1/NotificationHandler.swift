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
        } else if type == "RequestTripTimeOut" {
            self.notificationDelegate?.unableToFindDriver(data: additionalData)
        } else if type == "EndTrip" {
            self.notificationDelegate?.rideEnded(data: additionalData)
        } else if type == "LocationReachedTimeOut" {
            self.notificationDelegate?.locationReachedAndTimedout(data: additionalData)
        }
    }
    
    public func initializeOneSignalWithUserID(_ userId: String) {
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            OneSignal.sendTag("UserType", value: "User")
            OneSignal.sendTag("email", value: userId)
        })
        
        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)
    }
}

// This protocol (delgate) is used by the NotificationHandler and the SocketHandler and
protocol NotificationDelegate {
    func rideAccepted(data: JSON) -> Void
    func rideStarted(data: JSON) -> Void
    func rideEnded(data: JSON) -> Void
    func unableToFindDriver(data: JSON) -> Void
    func locationReachedAndTimedout(data: JSON) -> Void
}
