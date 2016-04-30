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
    
    var queueNum: Int = 1
    
    // Rider Latitude
    var startLatitude: Double = 0
    
    // Rider Longitude
    var startLongitude: Double = 0
    
    // Destination Latitude
    var destLat: Double = 0
    
    // Destination Longitude
    var destLong: Double = 0
    
    // Timeslot ID
    var selectedTID:Int = 0
    
    // Timer to schedule tasks
    var updateTimer: NSTimer?
    
    // Status of ride
    var rideStatus: String = "nonActive"
    
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
        
        let postUrl = ("http://\(self.appDelegate.baseURL)/Ryde/api/ride/getposition/" + self.FBid + "/" + (String)(self.selectedTID))
        self.getQueuePos(postUrl)
        // schedules task for every n second
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "updateQueue", userInfo: nil, repeats: true)
        
        
        /*
        self.queueLabel.text = (String)(self.queueNum)
        
        
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            //self.queueLabel.text = "1"
            
        })
        
        let seconds2 = 4.0
        let delay2 = seconds2 * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay2))
        
        dispatch_after(dispatchTime2, dispatch_get_main_queue(), {
            
            self.updateTimer!.invalidate()     //stops updateTimer (put in the post request when queue = 0 later)
            
            //self.queueLabel.text = "0"
            self.performSegueWithIdentifier("ShowCurrentRide", sender: nil)
            
        })
 */
 
    }
    
    func updateQueue(){
        let postUrl = ("http://\(self.appDelegate.baseURL)/Ryde/api/ride/getposition/" + self.FBid + "/" + (String)(self.selectedTID))
        self.getQueuePos(postUrl)
        print(queueNum)
        self.queueLabel.text = (String)(queueNum)
        if rideStatus == "active"
        {
            updateTimer?.invalidate()
            self.performSegueWithIdentifier("ShowCurrentRide", sender: nil)
        }
        //check if queueNum is 0, segue when it is.
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
            
            self.updateTimer?.invalidate()
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
    
    // Get Function for Canceling
    func getQueuePos(url : String) {
        
        //let params: [String : AnyObject] = [:]
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request)
        {
            (data, response, error) in
            guard let _ = data else {
                print("error calling")
                return
            }
            let json: NSDictionary?
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            } catch let dataError{
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                return
            }
            if let parseJSON = json {
                print(parseJSON)
                if let tempNum = parseJSON["position"] as? Int
                {
                    self.queueNum = tempNum
                }
                if let status = parseJSON["queueStatus"] as? String
                {
                    self.rideStatus = status
                }
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
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
