//
//  RequestRideViewController.swift
//  Ryde
//
//  Created by Franki Yeung on 4/7/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class RequestRideViewController: UIViewController {
    
    var queueNum: String = ""
    
    @IBOutlet var queueLabel: UILabel!
    
    override func viewDidLoad() {
        // gets rid of back button in navigation
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        
        self.title = "Ryde Requested"
        navigationItem.leftBarButtonItem = backButton
        
        super.viewDidLoad()
        
        self.queueLabel.text = "2"
        
        let seconds = 4.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            self.queueLabel.text = "1"
            
        })
        
        let seconds2 = 15.0
        let delay2 = seconds2 * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay2))
        
        dispatch_after(dispatchTime2, dispatch_get_main_queue(), {
            
            self.queueLabel.text = "0"
            self.performSegueWithIdentifier("ShowCurrentRide", sender: nil)
            
        })
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelRideClicked(sender: UIButton) {
        //post a cancellation
        navigationController?.popToRootViewControllerAnimated(true)
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
