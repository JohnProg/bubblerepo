//
//  SocketHandler.swift
//  bubble1
//
//  Created by Sumanth on 2/15/18.
//  Copyright © 2018 sumanths. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

class SocketHandler: WebSocketDelegate {
    // Singleton.
    private static var sharedInstance: SocketHandler = {
        return SocketHandler()
    }()
    
    private init() {
    }
    
    public static func shared() -> SocketHandler {
        return sharedInstance
    }
    
    var socket: WebSocket?
    var notificationDelegate: NotificationDelegate?
    
    public func setDelegate(_ delegate: NotificationDelegate) {
        self.notificationDelegate = delegate
    }
    
    public func connectSocket() {
        if let isConnected = self.socket?.isConnected {
            if isConnected {
                return
            }
        }
        let model = BubbleModel.shared()
        let ws_protocol = self.removeSpecialCharsFromString(text: model.userId)
        socket = WebSocket(url: URL(string: Constants.API_Server.WS_Base)!, protocols: [ws_protocol])
        socket?.delegate = self
        socket?.connect()
    }
    
    public func closeSocket() {
        self.socket?.disconnect()
    }
    
    public func handleMessage(data: JSON) {
        let type = data["Type"].stringValue
        print("Type: " + type)
        if type == "ConfirmTrip" {
            self.notificationDelegate?.rideAccepted(data: data)
        } else if type == "RequestTripTimeOut" {
            self.notificationDelegate?.unableToFindDriver(data: data)
        } else if type == "StartTrip" {
            self.notificationDelegate?.rideStarted(data: data)
        } else if type == "EndTrip" {
            self.notificationDelegate?.rideEnded(data: data)
        } else if type == "LocationReachedTimeOut" {
            self.notificationDelegate?.locationReachedAndTimedout(data: data)
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("got some text: \(text)")
        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            print(json)
            print(json["TripID"].stringValue)
            handleMessage(data: json)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
        let json = JSON(data)
        print(json)
    }
    
    private func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(text.filter {okayChars.contains($0) })
    }
}

