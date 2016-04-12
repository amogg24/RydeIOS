//
//  RiderRequestGroupTableViewController.swift
//  Ryde
//
//  Created by Franki Yeung on 4/7/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit

class RiderRequestGroupTableViewController: UITableViewController {
    
    // List of Active Groups
    var activeGroups:NSArray = NSArray()
    
    // List of Active TADs
    var activeTADs:NSArray = NSArray()
    
    // Rider Location
    var address: String! = ""
    
    // Rider FB id
    var FBid = ""
    
    // Rider Latitude
    var startLatitude: Double = 0
    
    // Rider Longitude
    var startLongitude: Double = 0
    
    // Destination Latitude
    var destLat: Double = 0
    
    // Destination Longitude
    var destLong: Double = 0
    
    // ID of chosen TAD
    var tadID = ""
    
    // Section Titles
    let section = ["Groups with Active Timeslots"]
    
    // Queue Position
    var queuePos:String! = "0"
    
    // join TAD success/failure
    var success: Bool = true
    
    var groupDictionary = [NSDictionary]()
    
    var selectedGroupInfo: NSDictionary?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        //Adds a navigation button to bring up alert to add TAD
        
        self.title = "Select Group"
        super.viewDidLoad()
        
        // Grab data from FB
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            self.FBid = (result.valueForKey("id") as? String)!
        })
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join TAD", style: .Plain, target: self, action:#selector(RiderRequestGroupTableViewController.joinTAD))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getUserTimeslots()
        /*
         get TAD list from server
         
         */
    }
    
    // Mark - Retrieve the users groups from the server
    
    func getUserTimeslots() {
        
        let url = NSURL(string: "http://\(self.appDelegate.baseURL)/Ryde/api/group/user/1")
        
        // Creaste URL Request
        let request = NSMutableURLRequest(URL:url!);
        
        // Set request HTTP method to GET. It could be POST as well
        request.HTTPMethod = "GET"
        
        // If needed you could add Authorization header value
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        // Execute HTTP Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString!)")
            
            
            let json: [NSDictionary]?
            
            do {
                
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? [NSDictionary]
                
            } catch let dataError{
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr!)'")
                // return or throw?
                return
            }
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, lets store its values into an array
                self.groupDictionary = parseJSON as [NSDictionary]
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr!)")
            }
            
            
        })
        
        task.resume()
        
        //        performSegueWithIdentifier("Home", sender: self)
        
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.section[section]
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.section.count
    }
    
    // Mark - TableView Delegates
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupDictionary.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("rideGroupCell") as! RideGroupTableViewCell
        
        if let groupTitle = groupDictionary[row]["title"] as? String {
            cell.rowName.text = groupTitle
        }
        
        return cell
    }
    
    // A row selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        selectedGroupInfo = groupDictionary[row]
        
        let JSONObject: [String : AnyObject] = [
            "driverUserId" : 1,
            "riderUserId" : 2,
            "tsId" : 3,
            "startLat" : 4,
            "startLon" : 5,
            "endLat"    : 6,
            "endLon"   : 7
        ]
        
        /*
         let JSONObject: [String : AnyObject] = [
         "fbTok" : self.FBid,
         "gID" : -1,
         "tID" : 1,
         "startLat" : 0,
         "startLon" : 0,
         "endLat"    : 0,
         "endLon"   : 0
         ]
         */
        //let postUrl = "http://\(self.appDelegate.baseURL)/Ryde/api/ride/request/" + self.FBid
        let postUrl = "http://\(self.appDelegate.baseURL)/Ryde/api/ride/request/JohnFBTok"
        //self.postRequest(JSONObject, url: postUrl)
        
        performSegueWithIdentifier("ShowRequestRide", sender: nil)
    }
    
    
    /*
     -------------------------
     MARK: - TAD Functions
     -------------------------
     */
    
    /*
     Creates an alert box when join TAD is clicked.
     */
    func joinTAD()
    {
        let alert = UIAlertController(title: "Enter TAD Passcode", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Passcode"
        })
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            let textField = alert.textFields![0] as UITextField
            
            self.passcodeError()
            //self.generateTADRequest(textField.text!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            //do nothing
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Sends passcode and fb Token to server side to attempt to join TAD
    func generateTADRequest (passcode: String)
    {
        let JSONObject: [String : String] = [
            "fbTok" : self.FBid,
            "TADPasscode" : passcode
        ]
        
        self.postTAD(JSONObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/timeslot/passcode")
    }
    
    func passcodeError()
    {
        let alert = UIAlertController(title: "Incorrect TAD Passcode", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            //do nothing
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Mark - POST function that takes in a JSON dictinoary and the URL to be POSTed to
    
    
    // SOURCE: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    func postTAD(params : Dictionary<String, String>, url : String) {
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
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
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            } catch let dataError{
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                self.passcodeError()
                return
            }
            
            
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                let success = parseJSON["success"] as? Int
                print("Succes: \(success)")
                
                self.getUserTimeslots()
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
        })
        
        task.resume()
    }
    
    
    // SOURCE: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    // Post Function for request
    func postRequest(params : Dictionary<String, AnyObject>, url : String) {
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
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
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            } catch let dataError{
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                return
            }
            
            
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                let success = parseJSON["success"] as? Int
                print("Succes: \(success)")
                
                //refresh Page
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
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "ShowRequestRide" {
            
            // Obtain the object reference of the destination view controller
            let requestRideViewController: RequestRideViewController = segue.destinationViewController as! RequestRideViewController
            
            //Pass the data object to the destination view controller object
            requestRideViewController.queueNum = queuePos
            
        }
    }
    
}