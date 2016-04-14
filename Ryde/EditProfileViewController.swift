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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var cellNumber = ""
    // Mark - Fields
    
    var FBid = ""
    var id = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellNumberTextField.text! = cellNumber

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
        print("id = \(id)")

    }
    
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        let name = profileName.text
        
        let fullNameArr = name?.componentsSeparatedByString(" ")
        
        let JSONObject: [String : AnyObject] = [
            
            "lastName"  : fullNameArr![(fullNameArr?.count)!-1],
            "firstName" : fullNameArr![0],
            "fbTok"     : FBSDKAccessToken.currentAccessToken().userID,
            "id"        : id,
            "phoneNumber" : cellNumberTextField.text!,
            "carMake"   : carMakeTextField.text!,
            "carModel"  : carModelTextField.text!,
            "carColor"  : carColorTextField.text!
        ]
        
        // Sends a POST to the specified URL with the JSON conent
        self.put(JSONObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/user/\(id)")
        //self.dismissViewControllerAnimated(true, completion: nil);
//
//        
        performSegueWithIdentifier("Edit", sender: self)
        
    }
    
    
    // Mark - Generic POST function that takes in a JSON dictinoary and the URL to be POSTed to
    
    
    // SOURCE: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    func put(params : Dictionary<String, AnyObject>, url : String) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        
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
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
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
    
    
    // Mark - Get Rid of Keyboard when Done Editing
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
