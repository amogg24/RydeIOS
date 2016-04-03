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


    override func viewDidLoad() {
        super.viewDidLoad()


        let fbButton = FBSDKLoginButton()
        
        fbButton.center = self.view.center
        
        fbButton.delegate = self

        self.view.addSubview(fbButton)
        
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
