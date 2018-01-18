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
    
    public static func requestRide(userId: String, startLocation: GMSPlace, endLocation: GMSPlace, date: Date, callback: @escaping (_ response:JSON, _ error:String ) -> Void) {
        let srcName = startLocation.name
        let destName = endLocation.name
        let srcPlaceId = startLocation.placeID
        let destPlaceId = endLocation.placeID
        
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
}
