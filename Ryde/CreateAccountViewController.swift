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

    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var profileName: UILabel!
    
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

    

}
