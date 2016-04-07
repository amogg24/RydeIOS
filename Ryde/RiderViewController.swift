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
            print(address)
            self.address.text = address
            self.previousAddress = address
        })
        
    }


}
