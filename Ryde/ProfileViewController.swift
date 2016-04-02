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

class ProfileViewController: UIViewController  {
    

    

    override func viewDidLoad() {
        super.viewDidLoad()


        let fbButton = FBSDKLoginButton()
        
        fbButton.center = self.view.center

        self.view.addSubview(fbButton)
        
    }
    


}
