//
//  ProfileViewController.swift
//  Ryde
//
//  Created by Joe Fletcher on 4/2/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate  {
    
    
    @IBOutlet var editButton: UIButton!
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var profileName: UILabel!
    
    var carMakeString = ""
    var carModelString = ""
    var carColorString = ""
    var phoneNumber = ""
    
    var groupDictionary = [NSDictionary]()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var profileTableView: UITableView!
    var nameLabels = ["Cell Number"]
    var infoLabel = [String]()
    
    let semaphore = dispatch_semaphore_create(0);
    
    
    // Mark - Fields
    
    var FBid = ""
    var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make the image a circle
        profileImage.layer.borderWidth = 1
        //profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.clearColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        
        //Set FB button to bottom of screen
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width * 0.5
        let screenHeight = screenSize.height * 0.9
        let a = CGPointMake(screenWidth, screenHeight)
        let fbButton = FBSDKLoginButton()
        fbButton.center = self.view.convertPoint(a, fromCoordinateSpace: self.view)
        fbButton.delegate = self
        self.view.addSubview(fbButton)
        
        // Grab data from FB
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            // Set Name
            self.profileName.text = result.valueForKey("name") as? String
            
            self.FBid = (result.valueForKey("id") as? String)!
            
            
            let url = NSURL(string: "https://graph.facebook.com/\(self.FBid)/picture?type=large&return_ssl_resources=1")
            // Set Image
            self.profileImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
            
            
            //Grab Data from API
            //self.getUserData(self.FBid)
        })
        
        profileTableView.separatorColor = UIColor.darkGrayColor()
        profileTableView.tableFooterView = UIView()
        
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nameLabels.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueReusableCellWithIdentifier("ProfileTableView") as! ProfileTableViewCell
        
        // Configure the cell...
        let rowNumber = indexPath.row
        cell.typeLabel.text! = nameLabels[rowNumber]
        
        //Get the User data
        getUserData(FBSDKAccessToken.currentAccessToken().userID)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        cell.infoLabel.text! = phoneNumber
        return cell
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
                // Need to add check if these exists in user
//                self.carMakeString = (parseJSON["carMake"] as? String)!
//                self.carModelString = (parseJSON["carModel"] as? String)!
//                self.carColorString = (parseJSON["carColor"] as? String)!
                
//                infoLabel = ["\(self.)"]
//                self.carInfoLabel.text = "\(self.carMakeString) \(self.carModelString) \(self.carColorString)"
                
                //Found data, signal semaphore
                self.phoneNumber  = (parseJSON["phoneNumber"] as? String)!
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
    
    @IBAction func editProfileButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("editProfile", sender: self)
        
    }
    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     
     This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
     You never call this method. It is invoked by the system.
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "editProfile" {
            
            // Obtain the object reference of the destination view controller
            let editProfileViewController: EditProfileViewController = segue.destinationViewController as! EditProfileViewController
            
            // Under the Delegation Design Pattern, set the addCityViewController's delegate to be self
            //            editRecruitViewController.dataObjectPassed = dataObjectPassed
        }
    }
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print("This should never be called")
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        print("User logged out")
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
        
        performSegueWithIdentifier("logOut", sender: self)
    }
    
}
