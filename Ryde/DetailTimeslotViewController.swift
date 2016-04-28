//
//  DetailTimeslotViewController.swift
//  Ryde
//
//  Created by Joe Fletcher on 4/27/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class DetailTimeslotViewController: UIViewController {

    
    @IBOutlet var startLabel: UILabel!
    
    @IBOutlet var startDataPicker: UIDatePicker!
    
    @IBOutlet var endLabel: UILabel!
    
    @IBOutlet var endDataPicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set Min Date of Date Pickers to be to TODAY's Date. Thus, no old TS will be created :)
        
        startDataPicker.minimumDate = NSDate()
        endDataPicker.minimumDate = NSDate()
    }
    

    @IBAction func datePickerChanged(sender: UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let strDate = dateFormatter.stringFromDate(sender.date)
        
        if sender == startDataPicker {
            startLabel.text = strDate
            
        }
        else if sender == endDataPicker {
            endLabel.text = strDate
            
        }
    }
    
    
}
