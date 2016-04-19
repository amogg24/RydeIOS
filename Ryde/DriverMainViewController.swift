//
//  DriverMainViewController.swift
//  Ryde
//
//  Created by Blake Duncan on 4/6/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class DriverMainViewController: UIViewController, SlideMenuDelegate   {
    
    var driverName = "Blake Duncan"
    var startTime = "10:00 p.m."
    var endTime = "1:00 a.m."
    var queueSize = 1
    var timeSlotID = 0;
    var id: Int!
    
    var carMakeString = ""
    var carModelString = ""
    var carColorString = ""
    var carInfo = ""
    var phoneNumber = ""
    var email = ""
    
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var queueLabel: UILabel!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var acceptRideButton: UIButton!
    @IBOutlet var btnShowMenu: UIBarButtonItem!
    
    var riderQueueDictionary = [NSDictionary]()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let semaphore = dispatch_semaphore_create(0);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        //hide back button and add slide menu button
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        headerLabel.text = "Welcome " + driverName
        startLabel.text = "Start Time: " + startTime
        endLabel.text = "End Time: " + endTime
        queueLabel.text = "Queue Size: " + String(queueSize)
        getUserData("JohnFBTok")
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        let status = true
        
        
        //Update the driver status to True (logged in)
        let JSONObject: [String : AnyObject] = [
            "driverStatus" : status,
            "id"        : id,
            /**
            "lastName"  : fullNameArr![(fullNameArr?.count)!-1],
            "firstName" : fullNameArr![0],
            "fbTok"     : FBSDKAccessToken.currentAccessToken().userID,
            "phoneNumber" : cellNumberTextField.text!,
            "carMake"   : carMakeTextField.text!,
            "carModel"  : carModelTextField.text!,
            "carColor"  : carColorTextField.text!,
            **/
        ]
        self.put(JSONObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/user/\(id)")
    }
    
    
    @IBAction func acceptRidePressed(sender: UIButton) {
        performSegueWithIdentifier("AcceptRide", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark - Generic POST function that takes in a JSON dictinoary and the URL to be POSTed to
    
    
    // SOURCE: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    func put(params : Dictionary<String, AnyObject>, url : String) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch {
            print(error)
            request.HTTPBody = nil
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            let json: NSDictionary?
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            } catch let dataError{
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                // return or throw?
                return
            }
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                let success = parseJSON["success"] as? Int
                print("Succes: \(success)")
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
        })
        
        task.resume()
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
        else if segue.identifier == "EditProfileFromDriver" {

            // Obtain the object reference of the destination (downstream) view controller
            //let driverMapViewController: DriverMapViewController = segue.destinationViewController as! DriverMapViewController
            
        }
    }
    
    // Functions for the slide out menu
    
    func slideMenuItemSelectedAtIndex(index: Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            //confirm Log out
            let alertController = UIAlertController(title: "Confirmation",
                message: "Are you sure you would like to log out?",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action: UIAlertAction!) in
                
                //Update the driver status to True (logged in)
                let JSONObject: [String : AnyObject] = [
                    "driverStatus" : false,
                    "id"        : self.id,
                ]
                self.put(JSONObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/user/\(self.id)")
                
                //Unhide tab bar and pop the current view from the navigation.
                self.tabBarController?.tabBar.hidden = false;
                self.navigationController?.popViewControllerAnimated(true)
                
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            presentViewController(alertController, animated: true, completion: nil)
            break
        case 1:
            performSegueWithIdentifier("EditProfileFromDriver", sender: self)
            break
        default:
            print("default\n", terminator: "")
        }
    }
    
    @IBAction func onSlideMenuButtonPressed(sender: UIBarButtonItem) {
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.mainScreen().bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clearColor()
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.enabled = false
        sender.tag = 10
        
        let menuVC : DriverMenuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DriverMenuViewController") as! DriverMenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRectMake(0 - UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height);
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            menuVC.view.frame=CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height);
            sender.enabled = true
            }, completion:nil)
    }
    
    // Mark - Retrieve the users groups from the server
    
    func getUserData(token: String) {
        print("RETRIEVE USER DATA")
        
        let url = NSURL(string: "http://\(self.appDelegate.baseURL)/Ryde/api/user/findByToken/\(token)")
        print(url)
        
        // Creaste URL Request
        let request = NSMutableURLRequest(URL:url!);
        
        // Set request HTTP method to GET. It could be POST as well
        request.HTTPMethod = "GET"
        
        // If needed you could add Authorization header value
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        // Execute HTTP Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            //print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            let json: NSDictionary?
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            } catch let dataError{
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                // return or throw?
                return
            }
            
            
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                //Check if the user has car data
                if parseJSON["carMake"] != nil {
                    self.carMakeString = (parseJSON["carMake"] as? String)!
                    self.carModelString = (parseJSON["carModel"] as? String)!
                    self.carColorString = (parseJSON["carColor"] as? String)!
                }
                
                //This data should always be found, signal semaphore once found
                self.id = (parseJSON["id"] as? Int)!
                dispatch_semaphore_signal(self.semaphore);
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
        })
        
        task.resume()
        
    }

    
}
