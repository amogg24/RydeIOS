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
        
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var groupDictionary = [NSDictionary]()
    
    var selectedGroupInfo: NSDictionary?
    
    var currentUser: NSDictionary?
    
    // Mark - IBActions
    
    @IBAction func addGroupPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func searchForGroupPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func unwindToGroupsViewController(sender: UIStoryboardSegue) {
        
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

        tableView.tableFooterView = UIView()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserGroups()

    }
    
    // Mark - Retrieve the users groups from the server
    
    func getUserGroups() {
        
        print("RETRIEVE USER GROUPS")
        
        let url = NSURL(string: "http://\(self.appDelegate.baseURL)/Ryde/api/group/user/1")
        
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
                // Okay, the parsedJSON is here, lets store its values into an array
                self.groupDictionary = parseJSON as [NSDictionary]
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
    
    
    // Mark - TableView Delegates
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupDictionary.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as UITableViewCell!

        if let groupTitle = groupDictionary[row]["title"] as? String {
            print(groupTitle)
            cell.textLabel!.text = groupTitle
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        selectedGroupInfo = groupDictionary[row]
        performSegueWithIdentifier("GroupSelected", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "GroupSelected") {
            let dest = segue.destinationViewController as! GroupDetailsTableViewController
            dest.groupInfo = selectedGroupInfo
        }
        else if (segue.identifier == "AddGroup") {
            let dest = segue.destinationViewController as! AddGroupViewController
            dest.currentUser = currentUser
        }
    }
}
