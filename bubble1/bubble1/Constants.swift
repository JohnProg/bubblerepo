//
//  Constants.swift
//  bubble1
//
//  Created by Sumanth on 7/17/17.
//  Copyright © 2017 sumanths. All rights reserved.
//

import Foundation

struct Constants {
    struct Keys {
        static let GoogleMaps_APIKey = "AIzaSyBghJGPJSGRO1ZBguupSE7MK--pXEmxAYU"
        static let OneSignal_APPID = "502ffde7-8ae9-4279-a611-4dce3053ac81"
        static let SendBird_APPID = "A0F1C638-F85F-4F79-BEE9-6D335268D9D1"
    }
    struct API_Server {
        static let Base = "http://ec2-35-153-75-38.compute-1.amazonaws.com:80"
        static let WS_Base = "ws://ec2-35-153-75-38.compute-1.amazonaws.com:80"
    }
    struct Stored_Values {
        struct Keys {
            static let Bubble_Place_Name = "bubblePlaceName"
            static let Bubble_Place_Lat = "bubblePlaceLat"
            static let Bubble_Place_Lng = "bubblePlaceLng"
            static let Bubble_Place_Place_ID = "bubblePlacePlaceID"
            
            static let Trip_Status = "tripStatus"
            static let Trip_Source = "tripSource"
            static let Trip_Destination = "tripDestination"
            static let Trip_Date = "tripDate"
            static let Trip_ID = "tripID"
        }
    }
    struct API_Return_Values {
        struct Trip_Status {
            static let Looking_For_Drivers = "LOOKING_FOR_DRIVERS"
            static let Trip_Accepted = "TRIP_ACCEPTED"
            static let Driver_Location_Reached = "DRIVER_LOCATION_REACHED"
            static let Trip_Started = "TRIP_ACTIVE"
            static let Trip_Complete = "TRIP_COMPLETE"
            static let Trip_Cancelled = "TRIP_CANCELED"
            static let Request_For_Cancellation = "REQUEST_FOR_CANCELLATION"
        }
    }
}
