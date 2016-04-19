//
//  EditGroupDetailsViewController.swift
//  Ryde
//
//  Created by Cody Cummings on 4/12/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class EditGroupDetailsViewController: UIViewController {

    // Mark - Fields
    
    var groupInfo: NSDictionary?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var adminList = [NSDictionary]()
    
    var memberList = [NSDictionary]()
    
    var initialMemberList = [NSDictionary]()
    
    var initialAdminList = [NSDictionary]()
    
    // Mark - IBOutlets
    
    
    
    @IBOutlet var groupNameTextField: UITextField!
    
    @IBOutlet var groupDescriptionTextView: UITextView!
    
    @IBOutlet var groupMemberTableView: UITableView!
    
    // Mark - IBActions
    
    @IBAction func saveEditedGroupPressed(sender: UIBarButtonItem) {
        if (groupNameTextField.text == "") {
            let alertController = UIAlertController(title: "Blank Group Name", message: "Please enter a name for the group!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if (groupDescriptionTextView.text == "") {
            let alertController = UIAlertController(title: "Blank Description", message: "Please enter a description for the group!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if (adminList.count == 0) {
            let alertController = UIAlertController(title: "No Admins", message: "You must select at least one member to be the administrator of the group!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
            //We have all of the fields ready, now we need to save the group and update the groupuser table
        else {
            
            let description = groupDescriptionTextView.text
            let title = groupNameTextField.text
            let id = String(groupInfo!["id"]!)
            
            //Make the group object
            let JSONGroupObject: [String : String] = [
                
                "description":  description!,
                "directoryPath": "none",
                "id" : id,
                "title": title!
            ]
            
            // Sends a PUT to the specified URL with the JSON conent
            self.putGroup(JSONGroupObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/group/\(id)")
            
            let adminSet = Set(adminList)
            let initialAdminSet = Set(initialAdminList)
            
            let memberSet = Set(memberList)
            let initialMemberSet = Set(initialMemberList)
            
            //gets all of the old admins that are no longer admins
            let removeAdminStatusSet = initialAdminSet.subtract(adminSet)
            
            print("Admins removed from group: \(removeAdminStatusSet)")
            
            //gets all of the new admins that were not admins before
            let addAdminStatusSet = adminSet.subtract(initialAdminSet)
            
            print("Admins added to group: \(addAdminStatusSet)")
            
            //gets all of the old members that are no longer members
            let removeMemberStatusSet = initialMemberSet.subtract(memberSet)
            
            print("Members removed from group: \(removeMemberStatusSet)")
            
            //gets all of the new members that were not members before
            let addMemberStatusSet = memberSet.subtract(initialMemberSet)
            
            print("Members added to group: \(addMemberStatusSet)")
            
            //set the group ID to the group we just updated
            let groupDict = [ "id" : id ]
            
            //add all of the members that were added to the group to the database
            //Do this first so that updates to the admin aren't affected
            for newMember in addMemberStatusSet {
                
                if let memberID = newMember["id"] {
                    let memberIDString = String(memberID)
                    let memberDict = [ "id" : memberIDString ]
                    
                    let JSONGroupUserObject = [
                        
                        "admin": "0",
                        "groupId": groupDict,
                        "userId": memberDict
                    ]
                    
                    //self.postGroupUser(JSONGroupUserObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/groupuser")
                }
            }
            
            //update all of the admin priviledges in the database that were revoked in the group
            //Do this second so that removing members isn't affected
            for initialAdmin in removeAdminStatusSet {
                
                if let memberID = initialAdmin["id"] {
                    let memberIDString = String(memberID)
                    let memberDict = [ "id" : memberIDString ]
                    
                    let JSONGroupUserObject = [
                        
                        "admin": "0",
                        "groupId": groupDict,
                        "userId": memberDict
                    ]
                    
                    //self.putGroupUser(JSONGroupUserObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/groupuser")
                }
            }
            
            //update all of the admin priviledges in the database that were added in the group
            for newAdmin in addAdminStatusSet {
                
                if let memberID = newAdmin["id"] {
                    let memberIDString = String(memberID)
                    let memberDict = [ "id" : memberIDString ]
                    
                    let JSONGroupUserObject = [
                        
                        "admin": "1",
                        "groupId": groupDict,
                        "userId": memberDict
                    ]
                    
                    //self.putGroupUser(JSONGroupUserObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/groupuser")
                }
            }
            
            //remove all of the members from the database that were removed from the group
            for initialMember in removeMemberStatusSet {
                
                if let memberID = initialMember["id"] {
                    
                    //self.deleteGroupUser("http://\(self.appDelegate.baseURL)/Ryde/api/groupuser/\(memberID)")
                }
            }
            
            
            let alertController = UIAlertController(title: "Group Successfully Updated!", message: "Your group \(title!) has been updated!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                self.performSegueWithIdentifier("UnwindToDetails-Save", sender: nil)
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteGroupPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "Are you sure?", message: "Once a group is deleted, it cannot be recovered", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            let id = self.groupInfo!["id"]!
            self.deleteGroup("http://\(self.appDelegate.baseURL)/Ryde/api/group/\(id)")
            self.performSegueWithIdentifier("UnwindToGroups-Delete", sender: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
        })

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - HTTP request methods
    
    func postGroupUser(params : NSDictionary, url : String) {
        print("POSTING TO GROUPUSER")
        
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
            
            let json: NSDictionary?
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            } catch let dataError{
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print("error: \(dataError)")
                return
            }
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's see what we sent
                print("parseJSON \(parseJSON)")
            }
        })
        
        task.resume()
    }
    
    func putGroupUser(params : NSDictionary, url : String) {
        
    }
    
    func putGroup(params : NSDictionary, url : String) {
        print("PUTTING UPDATE TO GROUP")
        
        print(url)
        
        self.groupInfo = params
        
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
            
            if(error != nil) {
                //do nothing
                print("updated group")
            }
            else {
                print(error)
            }
        })
        
        task.resume()

    }
    
    func deleteGroup(url: String) {
        print("DELETING GROUP")

        print(url)
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            guard let _ = data
                else {
                print("error calling DELETE on group")
                return
            }
        })
        task.resume()
    }
    
    func deleteGroupUser(url: String) {
        print("DELETING GROUP USER")
        
        print(url)
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            guard let _ = data
                else {
                    print("error calling DELETE on group user")
                    return
            }
        })
        task.resume()

    }
    
    // Mark - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupMemberTableView.tableFooterView = UIView()
        
        if let dict = groupInfo {
            if let title = dict["title"] as? String {
                groupNameTextField.text = title
            }
            if let description = dict["description"] as? String {
                groupDescriptionTextView.text = description
            }
        }
        
        initialAdminList = adminList
        initialMemberList = memberList
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // Mark - TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cell = groupMemberTableView.dequeueReusableCellWithIdentifier("memberCell") as! EditGroupDetailsTableViewCell!
        
        cell.selectionStyle = .None
        
        let memberRow = memberList[row]
        
        if let memberFirstName = memberRow["firstName"] as? String {
            if let memberLastName = memberRow["lastName"] as? String {
                cell.memberNameLabel.text = memberFirstName + " " + memberLastName
            }
        }
        cell.removeMember.tag = row
        cell.removeMember.addTarget(self, action: #selector(EditGroupDetailsViewController.removeMember(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.changeAdminStatusButton.setTitle("Make Admin", forState: UIControlState.Normal)
        
        if let memberID = memberRow["id"] {
            for admin in adminList {
                if let adminID = admin["id"] {
                    if String(memberID) == String(adminID) {
                        cell.changeAdminStatusButton.setTitle("Revoke Admin", forState: UIControlState.Normal)
                        break
                    }
                }
            }
        }
        
        cell.changeAdminStatusButton.tag = row
        cell.changeAdminStatusButton.addTarget(self, action: #selector(EditGroupDetailsViewController.changeAdminStatus(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }

    //MARK: - Tableview button method
    
    func removeMember(sender: UIButton) {
        let row = sender.tag
        let memberRow = memberList[row]
        if let memberID = memberRow["id"] {
            if let currentUser = appDelegate.currentUser {
                if let currentID = currentUser["id"] {
                    //check to see if the user is current user. if so, do nothing
                    if String(currentID) != String(memberID) {
                        
                        //check to see if the member being removed is admin, if so, remove from admin list as well
                        for (index, admin) in adminList.enumerate() {
                            if let adminID = admin["id"] {
                                if String(memberID) == String(adminID) {
                                    adminList.removeAtIndex(index)
                                    break
                                }
                            }
                        }
                        //now remove user from memberlist and update the tableview
                        memberList.removeAtIndex(row)
                        groupMemberTableView.reloadData()
                    }
                }
            }
        }
    }
    
    //Method to revoke or grant admin status to a member
    func changeAdminStatus(sender: UIButton) {
        let row = sender.tag
        let memberRow = memberList[row]
        if (sender.titleLabel!.text == "Make Admin") {
            adminList.append(memberRow)
            groupMemberTableView.reloadData()
        }
        else if (sender.titleLabel?.text == "Revoke Admin") {
            if let memberID = memberRow["id"] {
                for (index, admin) in adminList.enumerate() {
                    if let adminID = admin["id"] {
                        if String(memberID) == String(adminID) {
                            adminList.removeAtIndex(index)
                            groupMemberTableView.reloadData()
                            break
                        }
                    }
                }

            }
            
        }
    }
    
    //MARK: - prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "UnwindToDetails-Save") {
            let dest = segue.destinationViewController as! GroupDetailsTableViewController
            dest.groupInfo = self.groupInfo
        }
    }
    
}
