//
//  BubbleModel.swift
//  bubble1
//
//  Created by Sumanth on 1/7/18.
//  Copyright © 2018 sumanths. All rights reserved.
//

import Foundation
import SwiftyJSON

class BubbleModel {
    private static var sharedInstance:BubbleModel = {
        return BubbleModel()
    }()
    
    private init() {
    }
    
    public static func shared() -> BubbleModel {
        return sharedInstance
    }
    
    enum TripStatus: Int {
        case none=0, requested, accepted, started
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
        if self.activeTrip?.id != tripId {
            print("Cannot end trip for trip id: " + tripId)
            return false
        }
        self.activeTrip = nil
        self.tripStatus = .none
        return true
    }
    
    public func unableToFindDriver(tripId: String) -> Bool {
        if self.tripStatus != .requested || tripId != self.tripToBeScheduled?.id {
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
    
    public func saveState() {
        print("Saving state")
        func saveTripState(trip: TripDetails) {
            UserDefaults.standard.set(self.tripStatus.rawValue, forKey: Constants.Stored_Values.Keys.Trip_Status)
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:trip.source!), forKey: Constants.Stored_Values.Keys.Trip_Source)
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:trip.destination!), forKey: Constants.Stored_Values.Keys.Trip_Destination)
            if let d = trip.date {
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:d), forKey: Constants.Stored_Values.Keys.Trip_Date)
            }
        }
        
        if self.tripToBeScheduled != nil && self.tripStatus == .requested {
            // Save tripToBeScheduled
            saveTripState(trip: self.tripToBeScheduled!)
            UserDefaults.standard.set(self.tripToBeScheduled?.id, forKey: Constants.Stored_Values.Keys.Trip_ID)
        } else if self.activeTrip != nil {
            // Save active trip
            saveTripState(trip: self.activeTrip!)
            UserDefaults.standard.set(self.activeTrip?.id, forKey: Constants.Stored_Values.Keys.Trip_ID)
        }
    }
    
    public func loadState() {
        print("Loading from saved state")
        func loadTripState(trip: TripDetails) {
            if let srcObject = UserDefaults.standard.value(forKey: Constants.Stored_Values.Keys.Trip_Source) as? NSData {
                trip.source = NSKeyedUnarchiver.unarchiveObject(with: srcObject as Data) as? BubblePlace
                UserDefaults.standard.removeObject(forKey: Constants.Stored_Values.Keys.Trip_Source)
            }
            if let destObject = UserDefaults.standard.object(forKey: Constants.Stored_Values.Keys.Trip_Destination) as? NSData {
                trip.destination = NSKeyedUnarchiver.unarchiveObject(with: destObject as Data) as? BubblePlace
                UserDefaults.standard.removeObject(forKey: Constants.Stored_Values.Keys.Trip_Source)
            }
            if let dateObject = UserDefaults.standard.object(forKey: Constants.Stored_Values.Keys.Trip_Date) as? NSData {
                trip.date = NSKeyedUnarchiver.unarchiveObject(with: dateObject as Data) as? Date
                UserDefaults.standard.removeObject(forKey: Constants.Stored_Values.Keys.Trip_Source)
            }
        }
        
        if let trStatus = UserDefaults.standard.value(forKey: Constants.Stored_Values.Keys.Trip_Status) as? Int {
            self.tripStatus = TripStatus(rawValue: trStatus)!
            UserDefaults.standard.removeObject(forKey: Constants.Stored_Values.Keys.Trip_Status)
        } else {
            self.tripStatus = .none
        }
        
        if self.tripStatus == .none {
            return
        }
        if(self.tripStatus == .requested) {
            self.tripToBeScheduled = TripDetails()
            loadTripState(trip: self.tripToBeScheduled!)
            self.tripToBeScheduled!.id = UserDefaults.standard.object(forKey: Constants.Stored_Values.Keys.Trip_ID) as! String
            UserDefaults.standard.removeObject(forKey: Constants.Stored_Values.Keys.Trip_ID)
        } else {
            self.activeTrip = TripDetails()
            loadTripState(trip: self.activeTrip!)
            self.activeTrip!.id = UserDefaults.standard.object(forKey: Constants.Stored_Values.Keys.Trip_ID) as! String
            UserDefaults.standard.removeObject(forKey: Constants.Stored_Values.Keys.Trip_ID)
        }
    }
    
    public func getCurrentTrip() -> TripDetails? {
        if self.tripToBeScheduled != nil {
            return self.tripToBeScheduled!
        }
        if self.activeTrip != nil {
            return self.activeTrip!
        }
        return nil
    }
    
    public func updateModel(tripObject: JSON) {
        let tripStatusStr = tripObject["SessionState"].stringValue
        let tStatus = self.getTripStatusforString(tripStatusStr)
        
        if tStatus == .none {
            // No trips.
            self.tripStatus = .none
            self.activeTrip = nil
            self.tripToBeScheduled = nil
        } else if tStatus == .requested {
            let trip = getTripDetailsFromJSON(tripObject)
            self.tripStatus = tStatus
            self.tripToBeScheduled = trip
            self.activeTrip = nil
        } else {
            let trip = getTripDetailsFromJSON(tripObject)
            self.tripStatus = tStatus
            self.tripToBeScheduled = nil
            self.activeTrip = trip
        }
    }
    
    private func getTripDetailsFromJSON(_ tripObject: JSON) -> TripDetails {
        
        func getLatLongFromString(str: String) -> (Double, Double) {
            if str == "" {
                return (0.0,0.0)
            }
            let arr = str.components(separatedBy: ",")
            if arr.count != 2 {
                return (0.0,0.0)
            }
            if let d1 = Double(arr[0]), let d2 = Double(arr[1]) {
                return (d1, d2)
            }
            return (0.0,0.0)
        }
        
        let tripId = tripObject["TripID"].stringValue
        
        let startLoc = tripObject["StartLocation"].stringValue
        let dropLoc = tripObject["DropLocation"].stringValue
        let startLatLongStr = tripObject["Start-long-lat"].stringValue
        let dropLatLongStr = tripObject["Drop-long-lat"].stringValue
        let (slat, slong) = getLatLongFromString(str: startLatLongStr)
        let (dlat, dlong) = getLatLongFromString(str: dropLatLongStr)
        
        let srcPlace = BubblePlace(startLoc, latitude: slat, longitude: slong)
        let destPlace = BubblePlace(dropLoc, latitude: dlat, longitude: dlong)
        
        // Ignoring date for now.
        let trip = TripDetails(src: srcPlace, dest: destPlace)
        trip.id = tripId
        return trip
    }
    
    public func getTripStatusforString(_ str: String) -> BubbleModel.TripStatus {
        if str == Constants.API_Return_Values.Trip_Status.Looking_For_Drivers {
            return BubbleModel.TripStatus.requested
        } else if str == Constants.API_Return_Values.Trip_Status.Trip_Accepted || str == Constants.API_Return_Values.Trip_Status.Driver_Location_Reached {
            return BubbleModel.TripStatus.accepted
        } else if str == Constants.API_Return_Values.Trip_Status.Trip_Started {
            return BubbleModel.TripStatus.started
        }
        
        return BubbleModel.TripStatus.none
    }
}

class BubblePlace: NSObject, NSCoding {
    
    var name: String
    var latitude: Double
    var longitude: Double
    var placeID: String
    
    public init(_ placeName: String,latitude lat: Double,longitude long: Double, placeId: String = "placeID") {
        self.name = placeName
        self.latitude = lat
        self.longitude = long
        self.placeID = placeId
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: Constants.Stored_Values.Keys.Bubble_Place_Name)
        aCoder.encode(self.latitude, forKey: Constants.Stored_Values.Keys.Bubble_Place_Lat)
        aCoder.encode(self.longitude, forKey: Constants.Stored_Values.Keys.Bubble_Place_Lng)
        aCoder.encode(self.placeID, forKey: Constants.Stored_Values.Keys.Bubble_Place_Place_ID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = "Wrongly loaded"
        self.latitude = 0.0
        self.longitude = 0.0
        self.placeID = ""

        if let nameObject = aDecoder.decodeObject(forKey: Constants.Stored_Values.Keys.Bubble_Place_Name) as? String {
            self.name = nameObject
        }
        if let latObject = aDecoder.decodeDouble(forKey: Constants.Stored_Values.Keys.Bubble_Place_Lat) as Double? {
            self.latitude = latObject
        }
        if let lngObject = aDecoder.decodeDouble(forKey: Constants.Stored_Values.Keys.Bubble_Place_Lat) as Double? {
            self.longitude = lngObject
        }
        if let pIDObject = aDecoder.decodeObject(forKey: Constants.Stored_Values.Keys.Bubble_Place_Name) as? String {
            self.placeID = pIDObject
        }
    }
}

class TripDetails {
    public init() {
        
    }
    public init(src: BubblePlace, dest: BubblePlace) {
        source = src
        destination = dest
    }
    public init(src: BubblePlace, dest: BubblePlace, date: Date) {
        source = src
        destination = dest
        self.date = date
    }
    
    var source: BubblePlace?
    var destination: BubblePlace?
    var id: String = ""
    var date: Date?
    var driverEmail: String?
    var currentLat: Double?
    var currentLng: Double?
    
    var distance: Double = 0.0
    var price: Double = 0.0
}
