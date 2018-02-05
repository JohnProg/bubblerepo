//
//  WebUtil.swift
//  bubble1
//
//  Created by Sumanth on 1/7/18.
//  Copyright © 2018 sumanths. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import GooglePlaces

class WebUtil {
    public static func initUser(userId: String, callback: @escaping (_ response:JSON, _ error:String ) -> Void) {
        let url = "http://ec2-34-216-193-121.us-west-2.compute.amazonaws.com:443/inituser?EmailID=" + userId
        Alamofire.request(url, method: .post).responseJSON { response in
            print(response.request!)  // original URL request
            print(response.response!) // HTTP URL response
            print(response.data!)     // server data
            print(response.result)   // result of response serialization
            
            if(response.result.isSuccess) {
                let json = JSON(data: response.data!)
                callback(json, "")
            } else {
                callback(JSON(""), "error")
            }
            
        }
    }
    
    // Not integrated.
    public static func requestRide(userId: String, startLocation: GMSPlace, endLocation: GMSPlace, date: Date, callback: @escaping (_ response:JSON, _ error:String ) -> Void) {
        let srcName = startLocation.name
        let destName = endLocation.name
        let srcPlaceId = startLocation.placeID
        let destPlaceId = endLocation.placeID
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let startLat = startLocation.coordinate.latitude
        let startLng = startLocation.coordinate.longitude
        let destLat = endLocation.coordinate.latitude
        let destLng = endLocation.coordinate.longitude
        
        let url = Constants.API_Server.Base + "/requestTrip?" +
            "StartLocation=" + srcName + "&DropLocation=" + destName +
            "&StartTime=" + String(hour) + ":" + String(min) +
            "&StartDate=" + String(month) + "-" + String(day) + "-" + String(year) +
            "&ChildEmailID=" + userId +
            "&MapLink=maplink" +
            "&StartLatLng=" + String(startLat) + "," + String(startLng) +
            "&DropLatLng=" + String(destLat) + "," + String(destLng) +
            "&StartPlaceID=" + srcPlaceId + "&DropPlaceID=" + destPlaceId

        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print(escapedUrl!)
        Alamofire.request(escapedUrl!, method: .post).responseJSON { response in
            if(response.result.isSuccess) {
                print(response.request!)  // original URL request
                print(response.response!) // HTTP URL response
                print(response.data!)     // server data
                print(response.result)   // result of response serialization
                
                let json = JSON(data: response.data!)
                callback(json, "")
            } else {
                let err = response.result.error
                callback(JSON(""), (err?.localizedDescription)!)
            }
            
        }
    }
}
