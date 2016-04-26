//
//  TimeslotsTableViewController.swift
//  Ryde
//
//  Created by Joe Fletcher on 4/25/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class TimeslotsTableViewController: UITableViewController {

    // Mark - Fields
    
    var groupInfo: NSDictionary?
    
    var timeslotInfo = [NSDictionary]()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "\(groupInfo!["title"] as! String): Timeslot"
        
        
        getData()
        
    }
    
    // MARK - Get Data
    
    func getData() {
        
        // Fetch All Timeslots (if any) for THIS group
        
        let url = NSURL(string: "http://\(self.appDelegate.baseURL)/Ryde/api/timeslot/timeslotsForGroupSorted/\(String(groupInfo!["id"]!))")
        //        let url = NSURL(string: "http://jupiter.cs.vt.edu/Ryde/api/user")
        
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
            //            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //            print("responseString = \(responseString!)")
            
            
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
                self.timeslotInfo = parseJSON as [NSDictionary]
                
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
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return timeslotInfo.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let timeSlotsPerDate = timeslotInfo[section]["timeslots"] {
            return timeSlotsPerDate.count
        }
        else {
            return 0
        }
    
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
    
        
        if let timeSlotDate = timeslotInfo[section]["date"] {
            
            let exampleServerStartDateArray = timeSlotDate.componentsSeparatedByString("T")
            let exampleServerStartDate = exampleServerStartDateArray[0]
            
            // Start Date
            let tempDate = dateFormatter.dateFromString(exampleServerStartDate)
            let comp = calendar.components([.Day, .Month, .Year, .Hour, .Minute], fromDate: tempDate!)
            let startDateComponent = NSDateComponents()
            startDateComponent.year = comp.year
            startDateComponent.month = comp.month
            startDateComponent.day = comp.day
            startDateComponent.hour = comp.hour
            startDateComponent.minute = comp.minute
            // Get NSDate given the above date components
            let startDate = calendar.dateFromComponents(startDateComponent)
            
            
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
            
            // Format Start and End Dates
            
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            
            
            print("Start Date: \(dateFormatter.stringFromDate(startDate!))")
            //        print("End Date: \(dateFormatter.stringFromDate(endDate!))")
            
            return dateFormatter.stringFromDate(startDate!)
        }
        else {
           return "N/A"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("timeslotCell", forIndexPath: indexPath)
        
        if let timeSlotList = timeslotInfo[indexPath.section]["timeslots"] {

            if let timeSlotDic = timeSlotList[indexPath.row] {
                
                
                
                let startTime = timeSlotDic["startTime"]!!.componentsSeparatedByString("T")[1].componentsSeparatedByString("-")[0]
                
                print("Start Time: \(startTime)")
                
                let endTime = timeSlotDic["endTime"]!!.componentsSeparatedByString("T")[1].componentsSeparatedByString("-")[0]
                
                print("End Time: \(endTime)")
                
                cell.textLabel?.text = "\(startTime) - \(endTime)"
 
            }
        }
        
        cell.detailTextLabel?.text = "Driver(s): 2"
        
        return cell
    }

}
