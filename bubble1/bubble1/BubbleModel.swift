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
    
    enum TripStatus {
        case none, requested, accepted, started
    }
    
    var userId: String = ""
    var tripToBeScheduled: TripDetails?
    var activeTrip: TripDetails?
    
    var tripStatus: TripStatus = .none
    
    public func rideAccepted(tripId: String, driverEmail: String) -> Bool {
        if self.tripToBeScheduled != nil && self.tripStatus == .requested {
            self.activeTrip = self.tripToBeScheduled
            self.activeTrip!.id = tripId
            self.activeTrip!.driverEmail = driverEmail
            self.tripToBeScheduled = nil
            
            self.tripStatus = .accepted
            return true
        }
        return false
    }
    
    public func rideStarted(tripId: String) -> Bool {
        if self.tripStatus != .accepted {
            print("Trip status is not accepted. Ignoring request for trip Id: " + tripId)
            return false
        }
        self.tripStatus = .started
        return true
    }
    
    public func rideEnded(tripId: String) -> Bool {
        if self.activeTrip?.id != tripId || self.tripStatus != .started {
            print("Cannot end trip for trip id: " + tripId)
            return false
        }
        self.activeTrip = nil
        self.tripStatus = .none
        return true
    }
    
    public func unableToFindDriver(tripId: String) -> Bool {
        if self.tripStatus != .requested {
            print("Trip status is not requested. Ignoring request for trip Id: " + tripId)
            return false
        }
        self.tripStatus = .none
        self.tripToBeScheduled = nil
        return true
    }
    
    public func locationReachedAndTimedout(tripId: String) -> Bool {
        if self.tripStatus != .accepted {
            print("Trip status is not accepted. Ignoring request for trip Id: " + tripId)
            return false
        }
        self.activeTrip = nil
        return true
    }
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
