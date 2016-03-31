//
//  ViewController.swift
//  Ryde
//
//  Created by Joe Fletcher on 3/29/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    @IBOutlet var profilePicture: UIImageView!
    
    @IBOutlet var label: UILabel!
    
    @IBOutlet var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            print("No one has logged in")
        }
        else {
            print("Logged in")
        }

        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.delegate = self
        
        

        profilePicture.image = UIImage(named: "Ryde Transparent.png")

        

        label.text = "Not Logged In"
        label.textAlignment = NSTextAlignment.Center

        
    }
    
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error == nil) {
            print("Login complete")
            
            performSegueWithIdentifier("createAccount", sender: self)
            
            
            //print permissions, such as public_profile
            print(FBSDKAccessToken.currentAccessToken().permissions)
            
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                self.label.text = result.valueForKey("name") as? String
                
                let FBid = result.valueForKey("id") as? String
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                self.profilePicture.image = UIImage(data: NSData(contentsOfURL: url!)!)
            })
            
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        print("User logged out")
        
        profilePicture.image = UIImage(named: "Ryde Transparent.png")
        
        label.text = "Not Logged In"
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "createAccount" {
            
            let createAccountViewController: CreateAccountViewController = segue.destinationViewController as! CreateAccountViewController
            
            
            
            
            
        }
    }
    
    
    
}
