//
//  RiderViewController.swift
//  Ryde
//
//  Created by Joe Fletcher on 4/3/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // The label showcasing the current address of the User
    @IBOutlet var address: UILabel!
    
    // Map View Reference from StoryBoard
    @IBOutlet var mapView: MKMapView!
    
    // Location Manager instance
    let locationManager = CLLocationManager()
    
    // Geo Coder Reference
    var geoCoder: CLGeocoder!
    
    // Previous Address String
    var previousAddress: String!
    
    //current user Latitude
    var previousLat: Double = 0
    
    //current user Longitude
    var previousLong: Double = 0
    
    // Destination Latitude
    var destLat: Double = 0
    
    // Destination Longitude
    var destLong: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UINavigationBar.appearance().barTintColor = UIColor(red: 73, green: 181, blue: 138, alpha: 0)

        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestLocation()
        
        self.mapView.delegate = self
        
        geoCoder = CLGeocoder()
        
    }

    
    // Mark - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.first!
        self.mapView.centerCoordinate = location.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(location.coordinate, 1500, 1500)
        self.mapView.setRegion(reg, animated: true)
        geoCode(location)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error with Map View: " + error.localizedDescription)
    }

    
    // Mark - Map View Methods
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geoCode(location)
    }
    
    // Mark - Custom Methods
    
    func geoCode(location : CLLocation!){
        /* Only one reverse geocoding can be in progress at a time hence we need to cancel existing
         one if we are getting location updates */
        geoCoder.cancelGeocode()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (data, error) -> Void in
            guard let placeMarks = data as [CLPlacemark]! else {
                return
            }
            let loc: CLPlacemark = placeMarks[0]
            let addressDict : [NSString:NSObject] = loc.addressDictionary as! [NSString: NSObject]
            let addrList = addressDict["FormattedAddressLines"] as! [String]
            
            let address = addrList[0]
            self.address.text = address
            self.previousAddress = address
            self.previousLat = Double(location.coordinate.latitude)
            self.previousLong = Double(location.coordinate.longitude)
        })
        
    }

    @IBAction func RequestRydeClicked(sender: UIButton) {
        performSegueWithIdentifier("ShowRiderRequestGroup", sender: self)
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "ShowRiderRequestGroup" {
            
            // Obtain the object reference of the destination view controller
            let riderRequestGroupTableViewController: RiderRequestGroupTableViewController = segue.destinationViewController as! RiderRequestGroupTableViewController
            
            riderRequestGroupTableViewController.address = self.previousAddress
            riderRequestGroupTableViewController.startLatitude = self.previousLat
            riderRequestGroupTableViewController.startLongitude = self.previousLong
            riderRequestGroupTableViewController.destLat = self.destLat
            riderRequestGroupTableViewController.destLong = self.destLong
        }
    }
}
