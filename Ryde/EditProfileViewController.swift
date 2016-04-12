//
//  EditProfileViewController.swift
//  Ryde
//
//  Created by Andrew Mogg on 4/9/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var profileName: UILabel!
        
    @IBOutlet var cellNumberTextField: UITextField!
    @IBOutlet var carMakeTextField: UITextField!
    @IBOutlet var carModelTextField: UITextField!
    @IBOutlet var carColorTextField: UITextField!
    // Mark - Fields
    
    var FBid = ""

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
