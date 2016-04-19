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

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark, destination:String)
    func cancelSearch()
}

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, HandleMapSearch {

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
    
    // Last known current location of the user
    var lastLocation = CLLocation()
    
    // View for pick up/ drop off adreesses
    @IBOutlet var addressView: UIView!
    
    // Destination pin
    var selectedPin:MKPlacemark? = nil
    
    // Search Controller
    var resultSearchController:UISearchController? = nil
    
    // Destination Button to Search
    
    @IBOutlet var destinationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UINavigationBar.appearance().barTintColor = UIColor(red: 73, green: 181, blue: 138, alpha: 0)

        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.requestLocation()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        geoCoder = CLGeocoder()
        
    }
    
    // Mark - Cancel Search
    
    func cancelSearch() {
        
        if addressView.subviews.count > 1 {
            addressView.subviews.last?.removeFromSuperview()
            destinationButton.setTitle("Enter Destination", forState: UIControlState.Normal)
        }
            
        
    }
    
    
    // Mark - Destination Pin Drop
    
    func dropPinZoomIn(placemark:MKPlacemark, destination:String){
        
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        
        self.destLat = Double(placemark.coordinate.latitude)
        self.destLong = Double(placemark.coordinate.longitude)
        
        addressView.subviews.last?.removeFromSuperview()
        
        destinationButton.setTitle(destination, forState: UIControlState.Normal)
        
        //        The following code drops a pin where the user searched but we dont want that. Just in case im leaving it here.
        
        //        let span = MKCoordinateSpanMake(0.05, 0.05)
        //        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        //        mapView.setRegion(region, animated: true)
    }
    
    // Mark - Change Destination Button Clicked
    
    @IBAction func changeDestination(sender: UIButton) {
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        
        searchBar.placeholder = "Enter Destination"
        
        
        addressView.addSubview((resultSearchController?.searchBar)!)
        
        searchBar.sizeToFit()
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
    }
    

    
    // Mark - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location updated")
        
        self.locationManager.stopUpdatingLocation()
        
        lastLocation = locations.last!
        
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
    
    
    // Mark - Re-set to current location
    
    @IBAction func resetToCurrentLocation(sender: UIButton) {

        let userLocation = self.lastLocation
        
        let reg = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1500, 1500)
        self.mapView.setRegion(reg, animated: true)
    }
    
    
    // Mark - Request Ryde
    
    @IBAction func RequestRydeClicked(sender: UIButton) {
        performSegueWithIdentifier("ShowRiderRequestGroup", sender: self)
    }
    
    // Mark - Get Rid of Keyboard when Done Editing
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
            
            self.tabBarController?.tabBar.hidden = true
            
            riderRequestGroupTableViewController.address = self.previousAddress
            riderRequestGroupTableViewController.startLatitude = self.previousLat
            riderRequestGroupTableViewController.startLongitude = self.previousLong
            riderRequestGroupTableViewController.destLat = self.destLat
            riderRequestGroupTableViewController.destLong = self.destLong
            
            print("Ride Requested: Destination: \(self.previousLat) , \(self.previousLong)\t\(self.destLat) , \(self.destLong)")
        }
    }
    
}