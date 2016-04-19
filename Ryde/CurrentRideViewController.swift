//
//  CurrentRideViewController.swift
//  Ryde
//
//  Created by Franki Yeung on 4/12/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class CurrentRideViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Rider FB id
    var FBid = ""
    
    override func viewDidLoad() {
        // gets rid of back button in navigation
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        
        // Grab data from FB
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            self.FBid = (result.valueForKey("id") as? String)!
        })
        
        self.title = "Current Ride"
        
        navigationItem.leftBarButtonItem = backButton
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelRideClicked(sender: UIButton) {
        cancelRideAlert()
    }
    
    /*
     Creates an alert box cancel ride is clicked
     */
    func cancelRideAlert()
    {
        let alert = UIAlertController(title: "Are you sure you want to cancel ride?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.tabBarController?.tabBar.hidden = false
            
            let postUrl = ("http://\(self.appDelegate.baseURL)/Ryde/api/ride/cancel/" + self.FBid)
            self.postCancel(postUrl)
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            //do nothing
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // SOURCE: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    // Post Function for Canceling
    func postCancel(url : String) {
        
        //let params: [String : AnyObject] = [:]
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        
        let task = session.dataTaskWithRequest(request)
        {
            (data, response, error) in
            guard let _ = data else {
                print("error calling")
                return
            }
            print("canceling")
        }
        
        task.resume()
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
