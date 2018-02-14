//
//  AppDelegate.swift
//  bubble1
//
//  Created by Sumanth on 7/15/17.
//  Copyright © 2017 sumanths. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import Auth0
import OneSignal
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set background color of NavigationBar to Black
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        print(UserDefaults.standard.bool(forKey: "IsUserLoggedIn"))
        
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GMSServices.provideAPIKey(Constants.Keys.GoogleMaps_APIKey)
        GMSPlacesClient.provideAPIKey(Constants.Keys.GoogleMaps_APIKey)
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("Received Notification: \(notification!.payload.notificationID)")
            NotificationHandler.shared().handle(notification!)
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fullMessage = payload.body
            print("Message = \(fullMessage)")
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(additionalData!["actionSelected"])"
                }
            }
            NotificationHandler.shared().handle((result?.notification)!)
        }
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: Constants.Keys.OneSignal_APPID,
                                        handleNotificationReceived: notificationReceivedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        if UserDefaults.standard.bool(forKey: "IsUserLoggedIn") {
            // Set userId in the model, initialize OneSignal with the userId and navigate to the home screen.
            let userId = UserDefaults.standard.string(forKey: "userID")!
            BubbleModel.shared().userId = userId
            NotificationHandler.shared().initializeOneSignalWithUserID(userId)
            switchToHomeScreen()
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func switchToHomeScreen() {
        
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainNavVC")
        self.window?.rootViewController = vc
    }

    func showAuth0Screen() {
        DispatchQueue.main.async {
            Auth0
                .webAuth()
                .scope("openid profile")
                .audience("http://baybubble.auth0.com/userinfo")
                .start { result in
                    switch result {
                    case .success(let credentials):
                        print("Obtained credentials: \(credentials)")
                    case .failure(let error):
                        print("Failed with \(error)")
                    }
            }
        }
        
    }
}

