//
//  BubbleSplashScreen.swift
//  BubbleUserInterface
//
//  Created by Giridhar Malavali on 2/8/18.
//  Copyright © 2018 Giridhar Malavali. All rights reserved.
//

import UIKit

class BubbleSplashScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("splash screen")
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 50/255, green: 60/255, blue: 153/255, alpha: 1)
        
        perform(#selector(showNavController), with: nil, afterDelay: 3)
    }
    
    @objc func showNavController() {
        performSegue(withIdentifier: "BubbleLoginSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
