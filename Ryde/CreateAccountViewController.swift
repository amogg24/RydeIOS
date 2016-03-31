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
    
    @IBOutlet var carInfoMake: UITextField!
    
    @IBOutlet var carInfoModel: UITextField!
    
    @IBOutlet var carInfoColor: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //print permissions, such as public_profile
        print(FBSDKAccessToken.currentAccessToken().permissions)
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
        
            self.profileName.text = result.valueForKey("name") as? String
        
            let FBid = result.valueForKey("id") as? String
        
            let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
            self.profileImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
        })
    }
    
    
    // Mark - Package data to JSON and Submit to backend

    @IBAction func submitCreateAccount(sender: UIBarButtonItem) {
        
        let JSONObject: [String : AnyObject] = [
            "name" : "Joe Fletcher",
            "phone" : "7034857174"
        ]
        
        if NSJSONSerialization.isValidJSONObject(JSONObject) {
            var request: NSMutableURLRequest = NSMutableURLRequest()
            let url = "http://tendinsights.com/user"
            
            var err: NSError?
            
            request.URL = NSURL(string: url)
            request.HTTPMethod = "POST"
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(JSONObject, options:  NSJSONWritingOptions(rawValue:0))
            
            NSURLConnection.sendSynchronousRequest(request, queue: NSOperationQueue()) {(response, data, error) -> Void in
                if error != nil {
                    
                    print("error")
                    
                } else {
                    
                    print(response)
                    
                }
            }
        }
        
    }
    

}
