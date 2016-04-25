//
//  CurrentRideViewController.swift
//  Ryde
//
//  Created by Franki Yeung on 4/12/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FBSDKCoreKit
import FBSDKLoginKit

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}

class CurrentRideViewController: UIViewController, RiderSlideMenuDelegate, MKMapViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
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
    
    // Route between anotations
    var myRoute : MKRoute?
    
    // Mapkit showing the anotations
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        // Grab data from FB
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            self.FBid = (result.valueForKey("id") as? String)!
        })
        
        self.title = "Current Ride"
        
        // Add the side menu bar
        self.addSlideMenuButton()
        
        // Set map view delegate with controller
        self.mapView.delegate = self
        
        super.viewDidLoad()
        
        // Create the start coordinates
        let startLocation = CLLocationCoordinate2DMake(startLatitude, startLongitude)
        
        // Set the span of the map
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.03 , 0.03)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(startLocation, theSpan)
        mapView.setRegion(theRegion, animated: true)
    
        // Places an annotation for start location
        let annotation = CustomPointAnnotation()
        annotation.coordinate = startLocation
        annotation.title = "Your pick up location."
        annotation.imageName = "Marker Filled-50"
        mapView.addAnnotation(annotation)
        
        self.mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Show two anotation and a route instead if a destination was inputted
        if (destLong != 0 && destLat != 0)
        {
            let destLocation = CLLocationCoordinate2DMake(destLat, destLong)
            let destAnnotation = CustomPointAnnotation()
            destAnnotation.coordinate = destLocation
            destAnnotation.title = "Your drop off location."
            destAnnotation.imageName = "Destination"
            mapView.addAnnotation(destAnnotation)

            
            let directionsRequest = MKDirectionsRequest()
            let markStart = MKPlacemark(coordinate: CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude), addressDictionary: nil)
            let markDest = MKPlacemark(coordinate: CLLocationCoordinate2DMake(destAnnotation.coordinate.latitude, destAnnotation.coordinate.longitude), addressDictionary: nil)
            
            directionsRequest.source = MKMapItem(placemark: markStart)
            directionsRequest.destination = MKMapItem(placemark: markDest)
            directionsRequest.transportType = MKDirectionsTransportType.Automobile
            let directions = MKDirections(request: directionsRequest)
            directions.calculateDirectionsWithCompletionHandler
                {
                    (response, error) -> Void in
                    
                    if let routes = response?.routes where response?.routes.count > 0 && error == nil
                    {
                        let route : MKRoute = routes[0]
                        
                        //distance calculated from the request
                        print(route.distance) 
                        
                        //travel time calculated from the request
                        print(route.expectedTravelTime)
                        
                        self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.AboveRoads)
                        
                        var rect = route.polyline.boundingMapRect
                        rect.origin.x = rect.origin.x * 0.99
                        rect.origin.y = rect.origin.y * 0.99
                        rect.size.height = rect.size.height * 1.2
                        rect.size.width = rect.size.width * 1.2
                        
                        self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                    }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        anView!.image = UIImage(named:cpa.imageName)
        
        return anView
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
    
    //Handles Slide Menu interaction
    
    func slideMenuItemSelectedAtIndex(index: Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            print("Contact Driver\n", terminator: "")
            
            cancelRideAlert()
            
            break
        case 1:
            print("Cancel Ride\n", terminator: "")
            
            cancelRideAlert()
            
            break
        default:
            print("default\n", terminator: "")
        }
    }
    
    func openViewControllerBasedOnIdentifier(strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier(strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.System)
        btnShowMenu.setImage(self.defaultMenuImage(), forState: UIControlState.Normal)
        btnShowMenu.frame = CGRectMake(0, 0, 30, 30)
        btnShowMenu.addTarget(self, action: #selector(self.onSlideMenuButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 22), false, 0.0)
        
        UIColor.blackColor().setFill()
        UIBezierPath(rect: CGRectMake(0, 3, 30, 1)).fill()
        UIBezierPath(rect: CGRectMake(0, 10, 30, 1)).fill()
        UIBezierPath(rect: CGRectMake(0, 17, 30, 1)).fill()
        
        UIColor.whiteColor().setFill()
        UIBezierPath(rect: CGRectMake(0, 4, 30, 1)).fill()
        UIBezierPath(rect: CGRectMake(0, 11,  30, 1)).fill()
        UIBezierPath(rect: CGRectMake(0, 18, 30, 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }
    
    func onSlideMenuButtonPressed(sender : UIButton){
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
        
        let menuVC : RiderMenuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("RiderMenuViewController") as! RiderMenuViewController
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
}
