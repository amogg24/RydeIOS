//
//  CreateAccountViewController.swift
//  Ryde
//
//  Created by Joe Fletcher on 3/31/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class CreateAccountViewController: UIViewController {

    // Mark - Outlets
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var profileName: UILabel!

    @IBOutlet var phoneNumber: UITextField!
    
    // Mark - Fields
    
    var FBid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //print permissions, such as public_profile
        print(FBSDKAccessToken.currentAccessToken().permissions)
        
        // Grab data from FB
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
        
            // Set Name
            self.profileName.text = result.valueForKey("name") as? String
        
            self.FBid = (result.valueForKey("id") as? String)!
        
            let url = NSURL(string: "https://graph.facebook.com/\(self.FBid)/picture?type=large&return_ssl_resources=1")
            // Set Image
            self.profileImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
        })
    }
    
    
    // Mark - Package data to JSON and Submit to backend

    
    @IBAction func submitCreateAccount(sender: UIButton) {
        
        let JSONObject: [String : String] = [
            
            "driverStatus" : "false",
            "lastName"  : "Amjad",
            "firstName" : "Shawn",
            "fbTok"     : self.FBid,
            "phoneNumber" : "7034857174",
            "carMake" : "Toyota",
            "carModel" : "Camry",
            "carColor" : "Silver"
        ]
        
        // Sends a POST to the specified URL with the JSON conent
        self.post(JSONObject, url: "http://192.168.1.17:8080/Ryde/webresources/com.mycompany.entity.usertable")
        
        
        performSegueWithIdentifier("Home", sender: self)
        
    }

    
    // Mark - Generic POST function that takes in a JSON dictinoary and the URL to be POSTed to
    
    
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
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
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
    

}
