//
//  MessagingHandler.swift
//  bubble1
//
//  Created by Sumanth on 2/2/18.
//  Copyright © 2018 sumanths. All rights reserved.
//

import Foundation
import SendBirdSDK

class MessagingHandler {
    // Singleton.
    private static var sharedInstance:MessagingHandler = {
        return MessagingHandler()
    }()
    
    private init() {
    }
    
    public static func shared() -> MessagingHandler {
        return sharedInstance
    }
    
    var currentChannel: SBDOpenChannel?
    
    public func enterChannel(_ channelUrl: String) {
        SBDOpenChannel.getWithUrl(channelUrl) { (channel, error) in
            if error != nil {
                print("Error: %@", error!)
                return
            }
            
            channel?.enter(completionHandler: { (error) in
                if error != nil {
                    print("Error: %@", error!)
                    return
                }
                self.currentChannel = channel
            })
        }
    }
    
    public func exitChannel() {
        self.currentChannel?.exitChannel(completionHandler: { (error) in
            if error != nil {
                print("Error: %@", error!)
                return
            }
            
            self.currentChannel = nil
        })
    }
}

protocol MessagingDelegate {
    func coordinateChanged(_ latitude: Double, _ longitue: Double) -> Void
    func tripStarted() -> Void
    func tripEnded() -> Void
}
