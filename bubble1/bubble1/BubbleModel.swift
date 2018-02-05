//
//  BubbleModel.swift
//  bubble1
//
//  Created by Sumanth on 1/7/18.
//  Copyright © 2018 sumanths. All rights reserved.
//

import Foundation
import GooglePlaces

class BubbleModel {
    private static var sharedInstance:BubbleModel = {
        return BubbleModel()
    }()
    
    private init() {
    }
    
    public static func shared() -> BubbleModel {
        return sharedInstance
    }
    
    var userId: String = ""
    var tripToBeScheduled: TripDetails?
    var hasTripStarted: Bool = false
    var activeTrip: TripDetails?
}

class TripDetails {
    public init() {
        
    }
    public init(src: GMSPlace, dest: GMSPlace) {
        source = src
        destination = dest
    }
    public init(src: GMSPlace, dest: GMSPlace, date: Date) {
        source = src
        destination = dest
        self.date = date
    }
    
    var source: GMSPlace?
    var destination: GMSPlace?
    var id: String = ""
    var date: Date?
    var driverEmail: String?
    var currentLat: Double?
    var currentLng: Double?
    
    var distance: Double = 0.0
    var price: Double = 0.0
}
