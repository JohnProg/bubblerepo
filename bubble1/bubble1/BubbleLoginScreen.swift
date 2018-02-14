//
//  BubbleLoginScreen.swift
//  BubbleUserInterface
//
//  Created by Giridhar Malavali on 1/28/18.
//  Copyright © 2018 Giridhar Malavali. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BubbleLoginScreen: UIViewController {
    
    var loginType = "Child"
    var keyEmailID = ""
    
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var LoginSelector: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 50/255, green: 60/255, blue: 153/255, alpha: 1)
        EmailTextField.delegate = self
        
        EmailTextField.attributedPlaceholder = NSAttributedString(string: "Enter Child Email ID", attributes: [NSForegroundColorAttributeName: UIColor.black])
        EmailTextField.returnKeyType = .done
        EmailTextField.keyboardType = .emailAddress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginSelectorAction(_ sender: UISegmentedControl) {
        if LoginSelector.selectedSegmentIndex == 0 {
            loginType = "Child"
            EmailTextField.attributedPlaceholder = NSAttributedString(string: "Enter Child Email ID", attributes: [NSForegroundColorAttributeName: UIColor.black])
        } else if LoginSelector.selectedSegmentIndex == 1 {
            loginType = "Parent"
            EmailTextField.attributedPlaceholder = NSAttributedString(string: "Enter Parent Email ID", attributes: [NSForegroundColorAttributeName: UIColor.black])
            
        } else {
            loginType = "Unknown"
        }
        print("loginType:", loginType)
    }
    
    @IBAction func LoginBtnAction(_ sender: UIButton) {
        initUser(EmailTextField.text!)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func initUser(_ userId: String) {
        if userId.isEmpty {
            print("Empty user id string")
            let alert = UIAlertController(title: "Invalid input", message: "Enter a valid user ID", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                print("ok clicked")
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        WebUtil.initUser(userId: userId, callback: { response, error in
            print("Init user")
            if(response == JSON.null) {
                print(error)
                UserDefaults.standard.set(false, forKey: "IsUserLoggedIn")
                UserDefaults.standard.synchronize()
            } else {
                print("Init user success")
                BubbleModel.shared().userId = userId
                UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                UserDefaults.standard.set(userId, forKey: "userID")
                UserDefaults.standard.synchronize()
                NotificationHandler.shared().initializeOneSignalWithUserID(userId)
                
                (UIApplication.shared.delegate as! AppDelegate).switchToHomeScreen()
            }
        })
    }
}

extension BubbleLoginScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("text field returning...")
        
        self.initUser(EmailTextField.text!)
        return true
    }
}

