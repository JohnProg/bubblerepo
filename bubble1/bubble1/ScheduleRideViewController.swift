//
//  ScheduleRideViewController.swift
//  bubble1
//
//  Created by Sumanth on 1/16/18.
//  Copyright © 2018 sumanths. All rights reserved.
//

import Foundation
import UIKit

protocol ScheduleRideViewControllerDelegate: class {
    func rideScheduled(date: Date)
}

class ScheduleRideViewController: UIViewController {
    weak var delegate: ScheduleRideViewControllerDelegate?
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBAction func onOK(_ sender: Any) {
        print(self.datePicker.date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        print(dateFormatter.string(from: self.datePicker.date))
        
        self.delegate?.rideScheduled(date: self.datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        let today = NSDate() as Date
        self.datePicker.minimumDate = today
        self.datePicker.date = today
    }
}
