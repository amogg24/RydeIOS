//
//  TimeslotTableViewController.swift
//  Ryde
//
//  Created by Joe Fletcher on 4/22/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class TimeslotTableViewController: UITableViewController {

    // Mark - Fields
    
    var groupInfo: NSDictionary?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "\(groupInfo!["title"] as! String): Timeslot"
        
        getData()

        
    }

    // MARK - Get Data
    
    func getData() {
        
        // Fetch All Timeslots (if any) for THIS group
        
        let url = NSURL(string: "http://\(self.appDelegate.baseURL)/Ryde/api/timeslot/timeslotsForGroupSorted/\(String(groupInfo!["id"]!)))")
//        let url = NSURL(string: "http://jupiter.cs.vt.edu/Ryde/api/timeslotuser/gettads/10154133416887774")
        
        
        
        print(url)
        
        // Creaste URL Request
        let request = NSMutableURLRequest(URL:url!);
        
        // Set request HTTP method to GET. It could be POST as well
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
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
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                print(json)
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        })
        
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 1
        }
        else if (section == 1) {
            return 1
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Wednesday, April 27, 2016"
        }
        else if (section == 1) {
            return "Thursday, April 28, 2016"
        }
        else {
            return ""
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("timeslotCell", forIndexPath: indexPath)
//
//        let exampleServerStartDateArray = timeslots[indexPath.row]["startTime"]?.componentsSeparatedByString("T")
//        let exampleServerEndDateArray = timeslots[indexPath.row]["endTime"]?.componentsSeparatedByString("T")
//        
//        let exampleServerStartDate = exampleServerStartDateArray![0]
//        let exampleServerEndDate = exampleServerEndDateArray![0]
//        
//        let calendar = NSCalendar.currentCalendar()
//        calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        
//        // Start Date
//        var tempDate = dateFormatter.dateFromString(exampleServerStartDate)
//        var comp = calendar.components([.Day, .Month, .Year, .Hour, .Minute], fromDate: tempDate!)
//        let startDateComponent = NSDateComponents()
//        startDateComponent.year = comp.year
//        startDateComponent.month = comp.month
//        startDateComponent.day = comp.day
//        startDateComponent.hour = comp.hour
//        startDateComponent.minute = comp.minute
//        // Get NSDate given the above date components
//        let startDate = calendar.dateFromComponents(startDateComponent)
//        
//        
//        // End Date
//        
//        tempDate = dateFormatter.dateFromString(exampleServerEndDate)
//        comp = calendar.components([.Day, .Month, .Year, .Hour, .Minute], fromDate: tempDate!)
//        let endDateComponent = NSDateComponents()
//        endDateComponent.year = comp.year
//        endDateComponent.month = comp.month
//        endDateComponent.day = comp.day
//        endDateComponent.hour = comp.hour
//        endDateComponent.minute = comp.minute
//        
//        // Get NSDate given the above date components
//        let endDate = calendar.dateFromComponents(endDateComponent)
//        
//        // Format Start and End Dates
//        
//        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
//        
//        
//        let startTime = exampleServerStartDateArray![1].componentsSeparatedByString("-")[0]
//        let endTime = exampleServerEndDateArray![1].componentsSeparatedByString("-")[0]
//        
//        
//        print("Start Date: \(dateFormatter.stringFromDate(startDate!))")
//        print("Start Time: \(startTime)")
//        
//        
//        print("End Date: \(dateFormatter.stringFromDate(endDate!))")
//        print("End Time: \(endTime)")
//
//        
//        cell.textLabel?.text = "\(startTime) - \(endTime)"
        
        cell.detailTextLabel?.text = "Driver(s): 2"
        
        return cell
    }

}
