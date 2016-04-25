//
//  DriverMapViewController.swift
//  Ryde
//
//  Created by Blake Duncan on 4/6/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class DriverMapViewController: DriverBaseViewController, UIWebViewDelegate {
    
    //needed fields
    var riderName = "Blake Duncan"
    var rideID = 0
    var riderPhone = ""
    var riderLat = 37.234600
    var riderLng = -80.4102
    var driverLat = 37.231200
    var driverLng = -80.4104
    var destLat = 37.241660
    var destLng = -80.418267
    
    //False if driver hasn't picked up rider and true otherwise
    var hasRider = false
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var riderNameLabel: UILabel!
    @IBOutlet var driverButton: UIButton!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var callButton: UIButton!
    
    //google maps fields
    var mapsHtmlFilePath: String?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide back button and add slide menu
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        riderNameLabel.text = riderName
        hasRider = false
        
        mapsHtmlFilePath = NSBundle.mainBundle().pathForResource("maps", ofType: "html")
        
        let tempDriverLat = String(driverLat)
        let tempDriverLng = String(driverLng)
        let driverCoord = "\(tempDriverLat),\(tempDriverLng)"
        
        let tempRiderLat = String(riderLat)
        let tempRiderLng = String(riderLng)
        let riderCoord = "\(tempRiderLat),\(tempRiderLng)"
        
        let googleMapQuery: String = mapsHtmlFilePath! + "?start=\(driverCoord)&end=\(riderCoord)&traveltype=DRIVING"
        
        // Obtain the data passed from the upstream view controller VTPlaceInfoViewController
        let mapQuery = googleMapQuery
        
        /*
         Convert the mapQuery into an NSURL object and store its object reference
         into the local variable url. An NSURL object represents a URL.
         */
        let url: NSURL? = NSURL(string: mapQuery)
        
        /*
         Convert the NSURL object into an NSURLRequest object and store its object
         reference into the local variable request. An NSURLRequest object represents
         a URL load request in a manner independent of protocol and URL scheme.
         */
        let request = NSURLRequest(URL: url!)
        
        // Ask the webView object to display the web page for the given URL
        webView.loadRequest(request)
        
        // Do any additional setup after loading the view.
    }
    
    func pickupConfirmed(){
        headerLabel.text = "Drop Off"
        driverButton.setTitle("Ride Over", forState: .Normal)
        hasRider = true
        callButton.hidden = true
        cancelButton.hidden = true
        
        //load new directions
        let tempDriverLat = String(riderLat)
        let tempDriverLng = String(riderLng)
        let driverCoord = "\(tempDriverLat),\(tempDriverLng)"
        
        let tempDropLat = String(destLat)
        let tempDropLng = String(destLng)
        let dropOffCoord = "\(tempDropLat),\(tempDropLng)"
        
        let googleMapQuery: String = mapsHtmlFilePath! + "?start=\(driverCoord)&end=\(dropOffCoord)&traveltype=DRIVING"
        
        let mapQuery = googleMapQuery
        
        let url: NSURL? = NSURL(string: mapQuery)
        
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    // Mark - Cancel Button
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        //confirm pickup
        let alertController = UIAlertController(title: "Confirmation",
                                                message: "Are you sure you would like to cancel pickup?",
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
        
        // Present the alert controller by calling the presentViewController method
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Mark - Pick Up Button
    
    @IBAction func pickupButtonPressed(sender: UIButton) {
        if !hasRider {
            
            //confirm pickup
            let alertController = UIAlertController(title: "Confirm",
                                                    message: "Confirm that pickup has been made",
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                self.pickupConfirmed()
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            presentViewController(alertController, animated: true, completion: nil)
            
        } else if hasRider{
            
            //confirm ride over and drop off made
            let alertController = UIAlertController(title: "Confirm",
                                                    message: "Confirm that ride is over and drop off has been made",
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                
                //Ride is over so post to db
                let JSONObject: [String : String] = [
                    
                    "lastName"  : "",
                    "firstName" : "",
                    "fbTok"     : "",
                ]
                
                //Sends a POST to the specified URL with the JSON conent
                self.post(JSONObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/ride/endRide/\(self.rideID)")
                
                self.navigationController?.popViewControllerAnimated(true)
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    // Mark - Call Rider Button
    
    @IBAction func phoneButtonPressed(sender: UIButton) {
        
        if let url = NSURL(string: "tel://\(riderPhone)") {
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
    
    // SOURCE: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    func post(params : Dictionary<String, String>, url : String) {
        
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
        
        if segue.identifier == "RideOver" {
            
            // Obtain the object reference of the destination (downstream) view controller
            //let driverMapViewController: DriverMapViewController = segue.destinationViewController as! DriverMapViewController
            
            
        }
    }
    
}
