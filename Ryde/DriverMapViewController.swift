//
//  DriverMapViewController.swift
//  Ryde
//
//  Created by Blake Duncan on 4/6/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class DriverMapViewController: DriverBaseViewController, UIWebViewDelegate {
    
    //37.231200, -80.4102
    //37.234600, -80.4049
    //37.241660, -80.418267
    
    var riderName = "Blake Duncan"
    var addressOne = ""
    var addressTwo = ""
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
                self.navigationController?.popViewControllerAnimated(true)
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func phoneButtonPressed(sender: UIButton) {
//        let url:NSURL? = NSURL(string: "tel://\(4072573512)")
//        UIApplication.sharedApplication().openURL(url!)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
