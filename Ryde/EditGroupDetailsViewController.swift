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
        else {
            
            let description = groupDescriptionTextView.text
            let title = groupNameTextField.text
            let id = String(groupInfo!["id"]!)
            
            let JSONGroupObject: [String : String] = [
                
                "description":  description!,
                "directoryPath": "none",
                "id" : id,
                "title": title!
            ]
            
            // Sends a PUT to the specified URL with the JSON conent
            self.put(JSONGroupObject, url: "http://\(self.appDelegate.baseURL)/Ryde/api/group/\(id)")
            
            
            
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
    
    func put(params : NSDictionary, url : String) {
        print("PUTTING UPDATE TO GROUP")
        
        print(url)
        
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
        
        return cell
    }

    //MARK: - Tableview button method
    
    func removeMember(sender: UIButton) {
        let row = sender.tag
        let memberRow = memberList[row]
        
        if let memberID = memberRow["id"] as? String {
            if let currentUser = appDelegate.currentUser {
                if let currentID = currentUser["id"] as? String {
                    if currentID != memberID {
                        memberList.removeAtIndex(row)
                        groupMemberTableView.reloadData()
                    }
                }
            }
        }
    }
    
}
