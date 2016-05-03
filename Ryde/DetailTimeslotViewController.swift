//
//  DetailTimeslotViewController.swift
//  Ryde
//
//  Created by Joe Fletcher on 4/27/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class DetailTimeslotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet var startDateTextField: UITextField!
    @IBOutlet var endDateTextField: UITextField!
    @IBOutlet var groupMemberTableView: UITableView!
    @IBOutlet var groupMemberSearchBar: UISearchBar!
    @IBOutlet var scrollView: UIScrollView!
    
    //MARK: - Fields
    
    var searchBarResults = [NSDictionary]()
    var selectedGroupMembers = [String]()
    var newTimeslot = NSDictionary()
    var activeSearchBar: UISearchBar?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var searchActive : Bool = false
    var groupInfo : NSDictionary?
    var timeslotInfo : NSDictionary?
    var memberList = [NSDictionary]()
    var add = false
    var activeTextField = UITextField()
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addDoneButtonOnKeyboard()
        
        //We are populating this view with a previously created timeslot
        if (!add) {
            if let tsInfo = self.timeslotInfo {
                if let startTime = tsInfo["startTime"] as? String {
                    self.startDateTextField.text = startTime
                }
                if let endTime = tsInfo["endTime"] as? String {
                    self.endDateTextField.text = endTime
                }
            }
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.searchBar(self.groupMemberSearchBar, textDidChange: "")
        
    }
    
    //MARK: - IBActions
    
    @IBAction func saveTimeslot(sender: UIBarButtonItem) {
        
        if (startDateTextField.text == "" || endDateTextField.text == "") {
            let alertController = UIAlertController(title: "Select a valid period of time!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if (selectedGroupMembers.count == 0) {
            let alertController = UIAlertController(title: "No Drivers selected!", message: "Would you like to select drivers at a later time and continue anyways?", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                if (self.add) {
                    self.createTimeslot()
                }
                else {
                    self.updateTimeslot()
                }
            })
            alertController.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
            })
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            if (add) {
                createTimeslot()
            }
            else {
                updateTimeslot()
            }
        }

    }
    
    //MARK: - database operations
    
    func createTimeslot() {
        
    }
    
    func updateTimeslot() {
        
    }
    
    
    //MARK: startDateTextField Done Button
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(DetailTimeslotViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.startDateTextField.inputAccessoryView = doneToolbar
        self.endDateTextField.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        self.startDateTextField.resignFirstResponder()
        self.endDateTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //if we are dealing with the bithday textfield
        if (textField == startDateTextField || textField == endDateTextField)
        {
            activeTextField = textField
            let datePicker:UIDatePicker = UIDatePicker()
            datePicker.datePickerMode = UIDatePickerMode.DateAndTime
            textField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(DetailTimeslotViewController.updateTextfield(_:textField:)), forControlEvents: UIControlEvents.ValueChanged)
            let components = NSDateComponents()
            components.setValue(1, forComponent: NSCalendarUnit.Year);
            let date: NSDate = NSDate()
            let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))
            datePicker.maximumDate = expirationDate
            datePicker.minimumDate = NSDate()
        }
    }
    
    func updateTextfield(sender: UIDatePicker, textField: UITextField)
    {
        let dFormatter = NSDateFormatter();
        dFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        activeTextField.text = getDate(dFormatter.stringFromDate(sender.date))
    }
    
    //MARK: date functions
    
    func getDate(date: String) -> String
    {
        return date
    }
    
    // Mark: - Search Bar Delegates
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        activeSearchBar = searchBar
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        activeSearchBar = nil
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        //Clear out all old search results
        searchBarResults.removeAll()
        
        if (searchText == "") {
            searchBarResults = memberList
        }
        else {
            for member in memberList {
                if let memberFirstName = member["firstName"] as? String {
                    if let memberLastName = member["lastName"] as? String {
                        let fullName = memberFirstName + " " + memberLastName
                        let lowercaseFullName = fullName.lowercaseString
                        let lowercaseSearch = searchText.lowercaseString
                        if (lowercaseFullName.containsString(lowercaseSearch)) {
                            searchBarResults.append(member)
                        }
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.groupMemberTableView.reloadData()
        })
    }
    
    // MARK: - TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchBarResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cell = groupMemberTableView.dequeueReusableCellWithIdentifier("memberCell") as UITableViewCell!
        
        cell.selectionStyle = .None
        
        let memberRow = searchBarResults[row]
        
        if let memberFirstName = memberRow["firstName"] as? String {
            if let memberLastName = memberRow["lastName"] as? String {
                cell.textLabel!.text = memberFirstName + " " + memberLastName
                cell.textLabel?.textColor = UIColor.whiteColor()
            }
        }
        
        let memberID = String(memberRow["id"]!)
        if let _ = selectedGroupMembers.indexOf(memberID) {
            //remove the item at the found index
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        let cell = groupMemberTableView.dequeueReusableCellWithIdentifier("memberCell") as UITableViewCell!
        
        let memberRow = searchBarResults[row]
        let memberID = String(memberRow["id"]!)
        
        if let foundIndex = selectedGroupMembers.indexOf(memberID) {
            //remove the item at the found index
            cell.accessoryType = UITableViewCellAccessoryType.None
            selectedGroupMembers.removeAtIndex(foundIndex)
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedGroupMembers.append(memberID)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    
}
