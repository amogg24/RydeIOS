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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var adminList = [NSDictionary]()
    
    var memberList = [NSDictionary]()
    
    var currentUser : NSDictionary?
    
    var admin = false

    // Mark - IBActions
    
    @IBAction func unwindToGroupDetailsViewController(sender: UIStoryboardSegue) {
        
    }
    
    // Mark - IBOutlet
    
    @IBOutlet var editGroupButton: UIBarButtonItem!
    
    // Mark - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dict = groupInfo {
            if let groupTitle = dict["title"] as? String {
                self.title = groupTitle
            }
        }
        
        self.editGroupButton.enabled = false
        self.editGroupButton.tintColor = UIColor.clearColor()
        
        getGroupUsers()
        getGroupAdmins()
    }
    
    func getGroupUsers() {
        
        print("RETRIEVE GROUPS USERS")
        
        let id = groupInfo!["id"]!
        let url = NSURL(string: "http://\(self.appDelegate.baseURL)/Ryde/api/user/inGroup/\(id)")
        
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
                self.memberList = parseJSON as [NSDictionary]
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

    func getGroupAdmins() {
        print("RETRIEVE GROUPS ADMINS")
        
        let id = groupInfo!["id"]!
        let url = NSURL(string: "http://\(self.appDelegate.baseURL)/Ryde/api/group/admin/\(id)")
        
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
                self.adminList = parseJSON as [NSDictionary]
                
                let userID = String(self.currentUser!["id"]!)
                
                for admin in self.adminList {
                    let adminID = String(admin["id"]!)
                    
                    if (userID == adminID) {
                        self.admin = true
                        break
                    }
                }
                
                if (self.admin) {
                    self.editGroupButton.enabled = true
                    self.editGroupButton.tintColor = nil
                }
                
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
    }
    
    // Mark - TableView Delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 1
        }
        else if (section == 1) {
            return adminList.count
        }
        else if (section == 2) {
            return memberList.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupDetailCell") as UITableViewCell!
        if (section == 0) {
            if let dict = groupInfo {
                print(dict)
                if let groupDescription = dict["description"] as? String {
                    cell.textLabel!.text = groupDescription
                }
            }
        }
        else if (section == 1) {
            let memberInfo = adminList[row]
            if let firstName = memberInfo["firstName"] as? String {
                if let lastName = memberInfo["lastName"] as? String {
                    cell.textLabel!.text = firstName + " " + lastName
                }
            }
        }
        else if (section == 2) {
            let memberInfo = memberList[row]
            if let firstName = memberInfo["firstName"] as? String {
                if let lastName = memberInfo["lastName"] as? String {
                    cell.textLabel!.text = firstName + " " + lastName
                }
            }
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
            return "GROUP MEMBERS"
        }
        else {
            return ""
        }
    }
    
    // Mark - prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "EditGroup") {
            let dest = segue.destinationViewController as! EditGroupDetailsViewController
            dest.groupInfo = self.groupInfo
            dest.memberList = self.memberList
            dest.adminList = self.adminList
        }
    }
}
