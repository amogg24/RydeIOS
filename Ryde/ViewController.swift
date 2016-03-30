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
    
    
    var imageView : UIImageView!
    var label: UILabel!
    
    override func viewDidLoad() {
        
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            print("No one has logged in")
        }
        else {
            print("Logged in")
        }
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        
        loginButton.delegate = self
        
        self.view.addSubview(loginButton)
        
        
        imageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        imageView.center = CGPoint(x: view.center.x, y: 200)
        imageView.image = UIImage(named: "Ryde Transparent.png")
        view.addSubview(imageView)
        
        label = UILabel(frame: CGRectMake(0,0,200,30))
        label.center = CGPoint(x: view.center.x, y: 300)
        label.text = "Not Logged In"
        label.textAlignment = NSTextAlignment.Center
        view.addSubview(label)

        
    }
    
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error == nil) {
            print("Login complete")
            
            
            //print permissions, such as public_profile
            print(FBSDKAccessToken.currentAccessToken().permissions)
            
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                self.label.text = result.valueForKey("name") as? String
                
                let FBid = result.valueForKey("id") as? String
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                self.imageView.image = UIImage(data: NSData(contentsOfURL: url!)!)
            })
            
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        print("User logged out")
        
        imageView.image = UIImage(named: "Ryde Transparent.png")
        
        label.text = "Not Logged In"
        
        
    }
    
    
    
}
