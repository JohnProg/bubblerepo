//
//  HomeViewController.swift
//  bubble1
//
//  Created by Sumanth on 7/16/17.
//  Copyright © 2017 sumanths. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController,UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate, ScheduleRideViewControllerDelegate {
    
    var lat = 37.80
    var long = -122.21
    
    var instantRideButton: UIButton?
    var scheduleRideButton: UIButton?
    
    var myToolbar: UIToolbar?
    var toTextField: UITextField?
    var fromTextField : UITextField?
    
    var fromPlace: GMSPlace?
    var toPlace: GMSPlace?
    
    var markerFrom: GMSMarker?
    var markerTo: GMSMarker?
    
    var isPlaceFrom: Bool?
    var polyline: GMSPolyline?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Test code
//        WebUtil.initUser(userId: "pmalavalli@gmail.com", callback: { response, error in
//            print("callback")
//            print(response)
//        })
    }
    
    /** Giri.
     This method is called whenever the view appears. Read more here:
     https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/WorkWithViewControllers.html
     
     Basically, if this is the first time the view is appearing, we have to construct the UI elements (like the buttons, the
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if(self.instantRideButton == nil) { // Is this the first time. If yes, build all the UI elements and put it on the map.
            let viewWidth = view.frame.size.width
            let viewHeight = view.frame.size.height
            
            let frame1 = CGRect(x: 20, y: Int(viewHeight - 60), width: Int((viewWidth - 80)/2), height: 40)
            self.instantRideButton = self.createButton(rect: frame1, text: "Instant ride", color: UIColor.black)
            self.instantRideButton?.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
            
            let frame2 = CGRect(x: Int(viewWidth/2 + 20), y: Int(viewHeight - 60), width: Int((viewWidth - 80)/2), height: 40)
            self.scheduleRideButton = self.createButton(rect: frame2, text: "Schedule ride", color: UIColor.black)
            self.scheduleRideButton?.addTarget(self, action: #selector(scheduleRide(sender:)), for: UIControlEvents.touchUpInside)
            
            view.addSubview(self.instantRideButton!)
            view.addSubview(self.scheduleRideButton!)
            
            // make uitoolbar instance
//            myToolbar = UIToolbar(frame: CGRect(x: 0, y: self.view.bounds.size.height - 44, width: self.view.bounds.size.width, height: 40.0))
//
//            // set the position of the toolbar
//            myToolbar!.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-20.0)
//
//            // set the color of the toolbar
//            myToolbar!.barStyle = .blackTranslucent
//            myToolbar!.tintColor = UIColor.white
//            myToolbar!.backgroundColor = UIColor.black
//
//            // make a button
//            let myUIBarButtonGreen: UIBarButtonItem = UIBarButtonItem(title: "instant ride", style:.plain, target: self, action: #selector(onClickBarButton))
//            myUIBarButtonGreen.tag = 1
//            myUIBarButtonGreen.width = myToolbar!.frame.width / 2.0
//
//            let myUIBarButtonBlue: UIBarButtonItem = UIBarButtonItem(title: "schedule ride", style:.plain, target: self, action: #selector(onClickBarButton))
//            myUIBarButtonBlue.tag = 2
//            myUIBarButtonBlue.width = myToolbar!.frame.width / 2.0
//
//            // add the buttons on the toolbar
//            myToolbar!.items = [myUIBarButtonGreen, myUIBarButtonBlue]
            
            // add the toolbar to the view.
            //self.view.addSubview(myToolbar!)
            
            // text fields
            let navBarheight = self.navigationController?.navigationBar.frame.height
            fromTextField = UITextField(frame: CGRect(x: Int(self.view.frame.width * 0.1), y: Int(navBarheight! + ( (self.view.frame.height - navBarheight!) * 0.1 )), width: Int(self.view.frame.width * 0.8), height: 40))
            fromTextField?.placeholder = "From"
            fromTextField?.borderStyle = UITextBorderStyle.roundedRect
            fromTextField?.font = UIFont.systemFont(ofSize: 14)
            fromTextField?.delegate = self
            fromTextField?.isUserInteractionEnabled = true
            fromTextField?.isEnabled = true
            fromTextField?.addTarget(self, action: #selector(touchedDown(sender:)), for: UIControlEvents.touchDown)
            
            toTextField = UITextField(frame: CGRect(x: Int(self.view.frame.width * 0.1), y: Int(45 + navBarheight! + ( (self.view.frame.height - navBarheight!) * 0.1 )), width: Int(self.view.frame.width * 0.8), height: 40))
            toTextField?.placeholder = "To"
            toTextField?.borderStyle = UITextBorderStyle.roundedRect
            toTextField?.font = UIFont.systemFont(ofSize: 14)
            toTextField?.delegate = self
            toTextField?.addTarget(self, action: #selector(touchedDown(sender:)), for: UIControlEvents.touchDown)
            
            self.view.addSubview(fromTextField!)
            self.view.addSubview(toTextField!)
        } else {
            self.showPlacesOnMap()
        }
        
    }
    
    /** Giri
     This method puts the markers on the map. If both "from" and "to" places are non null, then the camera is adjusted such that both places show up on the map.
     */
    func showPlacesOnMap() {
        if(self.fromPlace != nil) {
            self.fromTextField?.text = self.fromPlace?.name
            self.fromTextField?.textColor = UIColor(red: 0.0, green: 255, blue: 0.0, alpha: 1)
            if(self.markerFrom == nil) {
                self.markerFrom = GMSMarker()
            }
            self.markerFrom?.position = CLLocationCoordinate2D(latitude: (self.fromPlace!.coordinate.latitude), longitude: (self.fromPlace!.coordinate.longitude))
            self.markerFrom?.title = "From"
            self.markerFrom?.snippet = self.fromPlace?.name
            self.markerFrom?.icon = GMSMarker.markerImage(with: UIColor(red:0, green: 255, blue: 0, alpha: 1))
            self.markerFrom?.map = self.view as? GMSMapView
        }
        if(self.toPlace != nil) {
            self.toTextField?.text = self.toPlace?.name
            self.toTextField?.textColor = UIColor(red: 127, green: 0, blue: 0, alpha: 1)
            
            if(self.markerTo == nil) {
                self.markerTo = GMSMarker()
            }
            self.markerTo?.position = CLLocationCoordinate2D(latitude: (self.toPlace!.coordinate.latitude), longitude: (self.toPlace!.coordinate.longitude))
            self.markerTo?.title = "To"
            self.markerTo?.snippet = self.toPlace?.name
            self.markerTo?.map = self.view as? GMSMapView
        }
        
        if(self.fromPlace != nil && self.toPlace != nil) {
            // Show both places on map.
            let bounds = GMSCoordinateBounds(coordinate: (self.markerFrom?.position)!, coordinate: (self.markerTo?.position)!)
            let map = (self.view as? GMSMapView)!
            
//            let edgeInsets = UIEdgeInsets()
//            
//            let camera = map.camera(for: bounds, insets: edgeInsets)!
//            map.camera = camera
            
            let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
            map.animate(with: cameraUpdate)
            
//            let cameraUpdate = GMSCameraUpdate.fit(bounds)
//            map?.animate(with: cameraUpdate)
        }
    }
    
    /** Giri.
     loadView is used to create a view manually. Since Google map views have to be inserted manually, I am using this method.
     https://developer.apple.com/documentation/uikit/uiviewcontroller/1621454-loadview
     */
    override func loadView() {
        super.loadView()
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: self.lat, longitude: self.long, zoom: 11.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 30, 0, self.bottomLayoutGuide.length + 10, 0)
        NSLog("top layout guide length: %@", self.topLayoutGuide.length)
        NSLog("bottom layout guide length: %@", self.bottomLayoutGuide.length)
        
        view = mapView
        
        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
    }
    
    /** Giri.
     Ignore this method. Its just a place holder for now. Monkeying around ashte.
     */
    func buttonClicked(sender: UIButton) {
        NSLog("clicked")
        let cameraUpdate = GMSCameraUpdate.scrollBy(x: 5.0, y: 10.0)
        let map = self.view as? GMSMapView
        
        map?.animate(with: cameraUpdate)
    }
    
    func scheduleRide(sender: UIButton) {
        print("Schedule ride")
        
        if(self.fromPlace == nil || self.toPlace == nil) {
            let alert = UIAlertController(title: "Error scheduling a ride", message: "Please specify both the source and destination locations", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                print("ok clicked")
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }

        // Update model
        let model = BubbleModel.shared()
        model.tripToBeScheduled = TripDetails(src: self.fromPlace!, dest: self.toPlace!)
    
        let storyboard = UIStoryboard(name: "ScheduleRideModal", bundle: nil)
        let controller:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideVC_ID") as! ScheduleRideViewController
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func createButton(rect: CGRect, text: String, color: UIColor) -> UIButton {
        let button = UIButton(frame: rect)
        button.backgroundColor = color
        button.setTitle(text, for: UIControlState.normal)
        
        return button
    }
    
    func onClickBarButton() {
        
    }
    
    // UITextfieldDelegate methods
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        NSLog("Did begin editing")
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    
    
    // End UITextfieldDelegate

    func touchedDown(sender: UIView) {
        NSLog("touched down")
        if(sender == self.fromTextField) {
            print("from")
            self.isPlaceFrom = true
        } else {
            print("to")
            self.isPlaceFrom = false
        }
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }

    /** Giri
     This method handles the user's selection.
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        if(self.isPlaceFrom == true) {
            self.fromPlace = place
        } else {
            self.toPlace = place
        }
        dismiss(animated: true, completion: nil)
        
//        let cameraUpdate = GMSCameraUpdate.setTarget(CLLocationCoordinate2D.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
//        let map = self.view as? GMSMapView
//        
//        DispatchQueue.main.async(execute: {
//            map?.animate(with: cameraUpdate)
//            map?.animate(toZoom: 11.0)
//        })
        if(self.fromPlace != nil && self.toPlace != nil) {
//            let mapView = self.view as! GMSMapView
//            mapView.clear()
//            self.showPlacesOnMap()
            fetchPath(source: self.fromPlace!, destination: self.toPlace!)
        }
        
    }
    
    /** Giri
     Get the path, given a source and destination. Each line (polyline) is put on the map.
     */
    func fetchPath(source: GMSPlace, destination: GMSPlace) {
        let originLat = source.coordinate.latitude
        let originLong = source.coordinate.longitude
        let destLat = destination.coordinate.latitude
        let destLong = destination.coordinate.longitude
        
        let origin = "\(originLat),\(originLong)"
        let destination = "\(destLat),\(destLong)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.Keys.GoogleMaps_APIKey)"
        print("url: " + url)
        
        Alamofire.request(url).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
//            self.polyline? =
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                var polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.isTappable = true
                polyline.strokeColor = UIColor.blue
                polyline.map = self.view as? GMSMapView
            }
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MaviewDelegate functions
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        print("In tap handler")
    }
    
    func rideScheduled(date: Date) {
        // Update model
        let model = BubbleModel.shared()
        model.tripToBeScheduled?.date = date
        
        let trip = model.tripToBeScheduled!
        
        // Make API call
        WebUtil.requestRide(userId: model.userId, startLocation: trip.source!, endLocation: trip.destination!, date: trip.date!, callback: { response, error in
            // If success, display a message that the request is being processed.
            
        })
    }

}

