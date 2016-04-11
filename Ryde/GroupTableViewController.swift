//
//  GroupTableViewController.swift
//  Ryde
//
//  Created by Cody Cummings on 4/5/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController {
    
    // Mark - Outlets
    
    @IBOutlet var searchBar: UISearchBar!
    
    // Mark - Fields
        
    var baseURL = "172.30.161.24:8080"//"jupiter.cs.vt.edu"
    
    var groupDictionary = Dictionary<Int, Dictionary<String, Dictionary<Int, String>>>()
    
    var selectedGroupInfo: Dictionary<String, Dictionary<Int, String>>?
    
    // Mark - IBActions
    
    @IBAction func addGroupPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func searchForGroupPressed(sender: UIBarButtonItem) {
    }
    
    //INFO FROM SERVER THAT I NEED
    /**
    * List of groups the user is a member of
    * On click of tableview cell, group information
    * On press of addGroup, need to be able to send group object to database
    * On press of addGroup, need to be able to retrieve facebook friends
    * On press of searchForGroup, need to be able to query groups by name
    * On press of searchForGroup, need to be able to send requestToJoinGroup object to database for multiple groups
    **/

    // Mark - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let groupNameDictionary : Dictionary<Int, String> = [0 : "Beta Balci Beta"]
        let groupDescriptionDictionary : Dictionary<Int, String> = [0 : "The best group ever"]
        let groupAdminDictionary : Dictionary<Int, String> = [0 : "Osman Balci"]
        let groupDriverDictionary : Dictionary<Int, String> = [0 : "Jennifer Lawrence"]
        let groupMemberDictionary : Dictionary<Int, String> = [0 : "Osman Balci", 1 : "Jennifer Lawrence"]
        groupDictionary[0] = ["GroupName" : groupNameDictionary, "GroupDescription" : groupDescriptionDictionary, "Admins" : groupAdminDictionary, "Drivers" : groupDriverDictionary, "GroupMembers" : groupMemberDictionary]
        //ask server what groups i am a part of and fill groupArray
        
        getUserGroups()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Mark - Retrieve the users groups from the server
    
    func getUserGroups() {
        
        print("RETRIEVE USER GROUPS")
        
        let url = NSURL(string: "http://\(self.baseURL)/Ryde/api/group/user/1)")
        
        print(url)
        
        // Creaste URL Request
        let request = NSMutableURLRequest(URL:url!);
        
        // Set request HTTP method to GET. It could be POST as well
        request.HTTPMethod = "GET"
        
        // If needed you could add Authorization header value
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        // Execute HTTP Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            
            // If Response is TRUE => User exists
            
            
            // Convert server json response to NSDictionary
            //            do {
            //                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
            //
            //                    // Print out dictionary
            //                    print(convertedJsonIntoDict)
            //
            //                    // Get value by key
            //                    let firstNameValue = convertedJsonIntoDict["userName"] as? String
            //                    print(firstNameValue!)
            //
            //                }
            //            } catch let error as NSError {
            //                print(error.localizedDescription)
            //            }
            
        }
        
        task.resume()
        
        //        performSegueWithIdentifier("Home", sender: self)
        
    }
    
    
    // Mark - TableView Delegates
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupDictionary.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as! GroupTableViewCell

        if let groupDictionary1 = groupDictionary[row] {
            if let groupDictionary2 = groupDictionary1["GroupName"] {
                cell.groupName.text = groupDictionary2[0]
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        if let information = groupDictionary[row] {
            selectedGroupInfo = information
        }
        performSegueWithIdentifier("GroupSelected", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "GroupSelected") {
            let dest = segue.destinationViewController as! GroupDetailsTableViewController
            dest.groupInfo = selectedGroupInfo
        }
    }
}
