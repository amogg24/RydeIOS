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

class CreateAccountViewController: UIViewController, UITextFieldDelegate  {

    // Mark - Outlets
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var profileName: UILabel!

    @IBOutlet var phoneNumber: UITextField!
    
    // Mark - Fields
    
    var baseURL = "172.30.173.109:8080"//"jupiter.cs.vt.edu"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CREATE ACCOUNT VIEW")

        //print permissions, such as public_profile
        print(FBSDKAccessToken.currentAccessToken().permissions)
        
        
        // Grab data from FB
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
        
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                // Set Name
                self.profileName.text = result.valueForKey("name") as? String
            
                let url = NSURL(string: "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID)/picture?type=large&return_ssl_resources=1")
                // Set Image
                self.profileImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
                
            }
            
        })

    }
    
    // Mark - Package data to JSON and Submit to backend

    
    @IBAction func submitCreateAccount(sender: UIButton) {
        
        let JSONObject: [String : String] = [
            
            "driverStatus" : "true",
            "lastName"  : "Fletcher",
            "firstName" : "Joe",
            "fbTok"     : FBSDKAccessToken.currentAccessToken().userID,
            "phoneNumber" : "7034857174",
            "carMake" : "Audi",
            "carModel" : "R8",
            "carColor" : "Sexy Black"
        ]
        
        // Sends a POST to the specified URL with the JSON conent
        self.post(JSONObject, url: "http://\(self.baseURL)/Ryde/api/user")
        
        
        performSegueWithIdentifier("Home", sender: self)
        
    }

    
    // Mark - Generic POST function that takes in a JSON dictinoary and the URL to be POSTed to
    
    
    // SOURCE: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    func post(params : Dictionary<String, String>, url : String) {
        
        
        print("POSTING TO NEW ACCOUNT")
        
        print(url)

        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        
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
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
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
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        if (textField == phoneNumber)
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false
        }
        else
        {
            return true
        }
    }
    

}
