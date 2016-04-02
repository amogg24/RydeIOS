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
    
    @IBOutlet var label: UILabel!
    
    @IBOutlet var loginButton: FBSDKLoginButton!
    
    
//    var fbResult = FBSDKLoginManagerLoginResult()
    
    override func viewDidLoad() {
        

        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.delegate = self
        
        label.textAlignment = NSTextAlignment.Center
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        checkIfLoggedIn()
    }
    
    func checkIfLoggedIn() {
        
        
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            print("No one has logged in")
        }
        else {
            print("Logged in")
            performSegueWithIdentifier("createAccount", sender: self)
        }
        
    }
    
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error == nil) {
            print("Login complete")
            
            performSegueWithIdentifier("createAccount", sender: self)
            
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        print("User logged out")
        
    }
    
}
