//
//  EventsTableViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 11/17/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit
import CoreData



class EventsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // Mark: Properties
    var eventsData:Array< Event > = Array < Event >()
    let serverUrl = "http://meetup.wcpsjshxnna.com/meetup-web/"
    var sections = Dictionary<String, Array< Event >>()
    var sortedSections = [String]()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var tableview: UITableView!
    
    enum ErrorHandler:ErrorType
    {
        case ErrorFetchingResults
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            //menuButton.target = self.revealViewController()
            //menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        get_data_from_url("\(serverUrl)get-events.php")
    }
    
    
    func get_data_from_url(url:String)
    {
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let postString = "start=0&limit=5&city=襄阳市"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let json = NSString(data: data!, encoding: NSASCIIStringEncoding)
                self.extract_json(json!)
                return
            })
            
        }
        
        task.resume()
        
    }
    
    
    func extract_json(data:NSString)
    {
        let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let json: AnyObject?

        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
            if let items = json!["act_info"] as? NSArray {
                for item in items
                {
                        if let data_block = item as? NSDictionary
                        {
                            let id = data_block["id"] as! String
                            let title = data_block["title"] as! String
                            let image = data_block["image_thumb"] as? String
                            let eventType = data_block["activity_type"] as! String
                            let eventTime = data_block["activity_time"] as! String
                            
                            let event:Event = Event(id:id, title:title, photoName:(image!), eventType:eventType)!
                            event.eventTime = eventTime
                            eventsData.append(event)
                        }
                }
                    
                do_table_refresh()
                
            }
            
        }
        catch let error as NSError {
            print("json error: \(error)")
        }
        
        groupEventsByDate()
    }
    
    
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableview.reloadData()
            return
        })
    }
    
    func groupEventsByDate(){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        for event in eventsData{
            let t = event.eventTime
            let date = t[t.startIndex.advancedBy(0)...t.startIndex.advancedBy(9)].toDateTime()
            let string = dateFormatter.stringFromDate(date)
            
            if self.sections.indexForKey(string) == nil {
                self.sections[string] = [event]
            }
            else {
                self.sections[string]!.append(event)
            }
        }
        self.sortedSections = Array(sections.keys).sort(<)
        self.tableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[sortedSections[section]]!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedSections[section]
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventTableViewCell", forIndexPath: indexPath) as! EventTableViewCell
        
        let eventSection = sections[sortedSections[indexPath.section]]
        let event = eventSection![indexPath.row]

        cell.nameLabel.text = event.title
        var image:UIImage?
        
        if (event.photoName == nil || event.photoName == "")
        {
            if event.eventType == "0"{
                image = UIImage(named: "festivalSample")!
            }
            else if event.eventType == "1" {
                image = UIImage(named: "boardGameSample")!
            }
            else if event.eventType == "2" {
                image = UIImage(named: "prisonBreakSample")!
            }
            else if event.eventType == "3" {
                image = UIImage(named: "exhibitionSample")!
            }
            else if event.eventType == "4" {
                image = UIImage(named: "startupLectureSample")!
            }
            else if event.eventType == "5" {
                image = UIImage(named: "movieWatchingSample")!
            }
            else if event.eventType == "6" {
                image = UIImage(named: "sportsSample")!
            }
            else if event.eventType == "7" {
                image = UIImage(named: "travelSample")!
            }
            else {
                image = UIImage(named: "otherEventSample")!
            }
            
            cell.photoImageView.image = image
            
        }
        else
        {
            let imageName = (event.photoName)!
            let imageUrl = "\(serverUrl)imgupload/activity_thumb_image/\(imageName)"
            //cell.imageView!.downloadedFrom(link: imageUrl, contentMode:.ScaleToFill)
            
            let url = NSURL(string: imageUrl)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, _, error) -> Void in
               
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    cell.photoImageView.image = image
                    cell.photoImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    cell.layoutSubviews()
                    //tv.setNeedsLayout()
                }
            }).resume()

        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}

extension String
{
    func toDateTime() -> NSDate
    {
        //Create Date Formatter
        let dateFormatter = NSDateFormatter()
        
        //Specify Format of String to Parse
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        //Parse into NSDate
        let dateFromString : NSDate = dateFormatter.dateFromString(self)!
        
        //Return Parsed Date
        return dateFromString
    }
}



