//
//  ViewController.swift
//  bubble1
//
//  Created by Sumanth on 7/15/17.
//  Copyright © 2017 sumanths. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet var facebookButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(red: 50/255, green: 60/255, blue: 153/255, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loginClicked(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).switchToHomeScreen()
    }
}

