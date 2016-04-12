//
//  GroupDetailsTableViewController.swift
//  Ryde
//
//  Created by Cody Cummings on 4/5/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class GroupDetailsTableViewController: UITableViewController {

    // Mark - Fields

    var groupInfo: NSDictionary?
    
    var baseURL = "jupiter.cs.vt.edu"//"jupiter.cs.vt.edu"
    
    var driverList = [NSDictionary]()
    
    var adminList = [NSDictionary]()
    
    var memberList = [NSDictionary]()
    
    // Mark - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dict = groupInfo {
            if let groupTitle = dict["title"] as? String {
                self.title = groupTitle
            }
        }
        
        getGroupUsers()
    }
    
    func getGroupUsers() {
        
        print("RETRIEVE GROUPS USERS")
        
        let url = NSURL(string: "http://\(self.baseURL)/Ryde/api/user/inGroup/1")
        
        print(url)
        
        // Creaste URL Request
        let request = NSMutableURLRequest(URL:url!);
        
        // Set request HTTP method to GET. It could be POST as well
        request.HTTPMethod = "GET"
        
        // If needed you could add Authorization header value
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        // Execute HTTP Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString!)")
            
            
            let json: [NSDictionary]?
            
            do {
                
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? [NSDictionary]
                
            } catch let dataError{
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr!)'")
                // return or throw?
                return
            }
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                print(parseJSON)
                // Okay, the parsedJSON is here, lets store its values into an array
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr!)")
            }
            
            
        })
        
        task.resume()
        
        //        performSegueWithIdentifier("Home", sender: self)
        
    }

    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Mark - TableView Delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 1
        }
        else if (section == 1) {
            return adminList.count
        }
        else if (section == 2) {
            return driverList.count
        }
        else if (section == 3) {
            return memberList.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupDetailCell") as! GroupDetailsTableViewCell
        if (section == 0) {
            if let dict = groupInfo {
                print(dict)
                if let groupDescription = dict["description"] as? String {
                    cell.groupDetailsCellText.text = groupDescription
                }
            }
        }
        else {
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        if (section == 0) {
            return 100
        }
        else {
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Description"
        }
        else if (section == 1) {
            return "ADMIN(S)"
        }
        else if (section == 2) {
            return "DRIVER(S)"
        }
        else if (section == 3) {
            return "GROUP MEMBERS"
        }
        else {
            return ""
        }
    }
}
