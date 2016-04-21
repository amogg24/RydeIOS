//
//  RequestRideViewController.swift
//  Ryde
//
//  Created by Franki Yeung on 4/7/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class RequestRideViewController: UIViewController {
    
    // Rider FB id
    var FBid = ""
    
    var queueNum: String = ""
    
    // Rider Latitude
    var startLatitude: Double = 0
    
    // Rider Longitude
    var startLongitude: Double = 0
    
    // Destination Latitude
    var destLat: Double = 0
    
    // Destination Longitude
    var destLong: Double = 0
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var queueLabel: UILabel!
    
    override func viewDidLoad() {
        // gets rid of back button in navigation
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        
        // Grab data from FB
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            self.FBid = (result.valueForKey("id") as? String)!
        })
        
        self.title = "Ryde Requested"
        navigationItem.leftBarButtonItem = backButton
        
        super.viewDidLoad()
        
        // schedules task for every n second
        var updateTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "updateQueue", userInfo: nil, repeats: true)
        
        self.queueLabel.text = "2"
        
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            self.queueLabel.text = "1"
            
        })
        
        let seconds2 = 4.0
        let delay2 = seconds2 * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay2))
        
        dispatch_after(dispatchTime2, dispatch_get_main_queue(), {
            
            updateTimer.invalidate()     //stops updateTimer (put in the post request when queue = 0 later)
            
            self.queueLabel.text = "0"
            self.performSegueWithIdentifier("ShowCurrentRide", sender: nil)
            
        })
        // Do any additional setup after loading the view.
    }
    
    func updateQueue(){
        print("function called")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelRideClicked(sender: UIButton) {
        //post a cancellation
        cancelRideAlert()
    }
    
    /*
     Creates an alert box cancel ride is clicked
     */
    func cancelRideAlert()
    {
        let alert = UIAlertController(title: "Are you sure you want to cancel ride?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.tabBarController?.tabBar.hidden = false
            
            let postUrl = ("http://\(self.appDelegate.baseURL)/Ryde/api/ride/cancel/" + self.FBid)
            self.postCancel(postUrl)
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            //do nothing
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // SOURCE: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    // Post Function for Canceling
    func postCancel(url : String) {
        
        //let params: [String : AnyObject] = [:]
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        
        let task = session.dataTaskWithRequest(request)
        {
            (data, response, error) in
            guard let _ = data else {
                print("error calling")
                return
            }
            print("canceling")
        }
        
        task.resume()
    }
    
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "ShowCurrentRide" {
            
            // Obtain the object reference of the destination view controller
            let currentRiderViewController: CurrentRideViewController   = segue.destinationViewController as! CurrentRideViewController
            
            //Pass the data object to the destination view controller object
            currentRiderViewController.startLatitude = self.startLatitude
            currentRiderViewController.startLongitude = self.startLongitude
            currentRiderViewController.destLat = self.destLat
            currentRiderViewController.destLong = self.destLong
        }
    }
    
}
