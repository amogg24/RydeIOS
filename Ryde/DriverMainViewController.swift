//
//  DriverMainViewController.swift
//  Ryde
//
//  Created by Blake Duncan on 4/6/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class DriverMainViewController: DriverBaseViewController {
    
    var driverName = "Blake Duncan"
    var startTime = "10:00 p.m."
    var endTime = "1:00 a.m."
    var queueSize = 0
    
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var queueLabel: UILabel!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var acceptRideButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide back button and add slide menu button
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.addSlideMenuButton()
        
        headerLabel.text = "Welcome " + driverName
        startLabel.text = "Start Time: " + startTime
        endLabel.text = "End Time: " + endTime
        queueLabel.text = "Queue Size: " + String(queueSize)
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func acceptRidePressed(sender: UIButton) {
        performSegueWithIdentifier("AcceptRide", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    -------------------------
    MARK: - Prepare for Segue
    -------------------------
    */
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "AcceptRide" {
            
            // Obtain the object reference of the destination (downstream) view controller
            //let driverMapViewController: DriverMapViewController = segue.destinationViewController as! DriverMapViewController
            
            
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
