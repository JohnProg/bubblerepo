//
//  ViewController.swift
//  bubble1
//
//  Created by Sumanth on 7/15/17.
//  Copyright © 2017 sumanths. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleMaps

class LoginViewController: UIViewController {

    @IBOutlet var facebookButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loginClicked(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).switchToHomeScreen()
        
        // navigation has to be done in the app delegate
        
        
        /*
        let loginManager = LoginManager()
        loginManager.loginBehavior = .native
        loginManager.logOut()
        loginManager.logIn([ .publicProfile, .email, .userFriends], viewController: self) {
            loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
                    self.facebookButton.isEnabled = true
                }
                
                break
            case .cancelled:
                print("User cancelled login.")
                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
                    self.facebookButton.isEnabled = true
                }
                
                break
            case .success:
                print("Logged in!")
                if let accessToken = AccessToken.current {
                    
                    // User is logged in, use 'accessToken' here.
                    print("MY ACCESS TOKEN:\(accessToken)")
                    
//                    self.fbAccessToken = accessToken.authenticationToken
//                    
//                    let defaults = UserDefaults.standard
//                    defaults.set(self.fbAccessToken, forKey: "FB_TOKEN")
//                    
//                    Tokens.sharedInstance.Token = self.fbAccessToken
                    
                    self.getFBUserDetails()
                }
                break
            }
        }
 */

    }
    
    func getFBUserDetails() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                print("success")
                break
            case .failed(let error):
                print(error)
                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
                    print("failed")
                    self.facebookButton.isEnabled = true
                }
                
            }
        }
    }


}

