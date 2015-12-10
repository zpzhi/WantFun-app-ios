//
//  ProfileTableViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 12/10/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet var eventsTableView: UITableView!
    
    let loginId: String = "10"
    let loginUserName: String = "easonlove"
    let serverUrl = "http://meetup.wcpsjshxnna.com/meetup-web/"
    var profileDetial: User?
    var joinedEvents:Array< Event > = Array < Event >()
    var publishedEvents:Array< Event > = Array < Event >()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        get_UserDetail_from_url("\(serverUrl)get-user-detail.php")
        get_joinedEvents_from_url("\(serverUrl)get-events-by-user.php")
        get_publishedEvents_from_url("\(serverUrl)list-hosting-events-by-user.php")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Communcation with Server
    func get_UserDetail_from_url(url:String)
    {
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let postString = "userName=\(loginUserName)"
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
                if (json != "[]" && json != nil){
                    self.extract_json_host(json!)
                }
                return
            })
            
        }
        
        task.resume()
        
    }
    
    func extract_json_host(data:NSString)
    {
        let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let json: AnyObject?
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
            if let items = json!["user_info"] as? NSArray {
                for item in items
                {
                    if let data_block = item as? NSDictionary
                    {
                        let id = data_block["id_user"] as! String
                        let username = data_block["username"] as! String
                        let thumb = data_block["image_thumb"] as? String
                        let image = data_block["image_name"] as? String
                        let realName = data_block["name"] as? String
                        let phoneNumber = data_block["phone_number"] as? String
                        let userDescription = data_block["user_description"] as? String
                        
                        profileDetial = User(id: id)!
                        profileDetial!.name = username ?? ""
                        profileDetial!.photoName = phoneNumber ?? ""
                        profileDetial!.realName = realName ?? ""
                        profileDetial!.description = userDescription ?? ""
                        
                        if (thumb != nil && thumb != "NULL"){
                            profileDetial?.photoName = image!
                            profileDetial?.thumbnailName = thumb!
                            
                            getImageFromServer(image!, imageView: profileImage, folder: "user_image", flag: 0)
                        }else{
                            
                            let image = UIImage(named: "defaultUser")!
                            let imageLayer: CALayer?  = profileImage.layer
                            imageLayer!.cornerRadius = profileImage.frame.size.width/2
                            imageLayer!.masksToBounds = true
                            profileImage.image = image
                            
                        }
                        profileUserName.text = username ?? ""
                        
                    }
                }
            }
            
            
        }
        catch let error as NSError {
            print("json error: \(error)")
        }
    }
    
    func get_joinedEvents_from_url(url:String)
    {
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let postString = "userId=\(loginId)"
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
                if (json != "[]" && json != nil){
                    self.extract_json_join(json!)
                }
                return
            })
            
        }
        
        task.resume()
        
    }
    
    func extract_json_join(data:NSString)
    {
        joinedEvents.removeAll()
        let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let json: AnyObject?
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
            if let items = json!["activity_info"] as? NSArray {
                
                for item in items
                {
                    if let innerArray = item as? NSArray{
                        for iner_item in innerArray{
                            if let data_block = iner_item as? NSDictionary
                            {
                                let id = data_block["id"] as! String
                                let title = data_block["title"] as! String
                                let address = data_block["activity_address"] as! String
                                let activityTime = data_block["activity_time"] as! String
                                //let postTime = data_block["post_time"] as? String
                                let duration = data_block["activity_duration"] as! String
                                let phone = data_block["phone_number"] as? String
                                let detail = data_block["activity_detail"] as! String
                                let activityType = data_block["activity_type"] as? String
                                let city = data_block["city"] as! String
                                let state = data_block["state"] as? String
                                let imageName = data_block["image_name"] as? String
                                let eventCreator = data_block["event_creator"] as? String

                                let event:Event = Event(id:id, title:title, eventType:activityType!)!
   
                                if (imageName != nil && imageName != "NULL"){
                                    event.imageName = imageName!
                                    event.thumbImageName = imageName!
                                }
                                event.city = city ?? ""
                                event.description = description ?? ""
                                event.duration = duration ?? ""
                                event.phoneNumber = phone ?? ""
                                event.description = detail ?? ""
                                event.eventTime = activityTime ?? ""
                                event.location = address ?? ""
                                event.eventType = activityType ?? ""
                                event.eventCreator = eventCreator ?? ""
                                event.state = state ?? ""

                                joinedEvents.append(event)
                                
                                
                            }
                        }
                    }
                }
                
                do_joinedEvents_section_refresh()
                
            }
            
            
        }
        catch let error as NSError {
            print("json error: \(error)")
        }
    }
    
    func do_joinedEvents_section_refresh(){
        self.eventsTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        return
    }
    
    func get_publishedEvents_from_url(url:String)
    {
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let postString = "userId=\(loginId)"
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
                if (json != "[]" && json != nil){
                    self.extract_json_publish(json!)
                }
                return
            })
            
        }
        
        task.resume()
        
    }
    
    func extract_json_publish(data:NSString)
    {
        publishedEvents.removeAll()
        let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let json: AnyObject?
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
            if let items = json!["activity_info"] as? NSArray {
                
                for item in items
                {
                            if let data_block = item as? NSDictionary
                            {
                                let id = data_block["id"] as! String
                                let title = data_block["title"] as! String
                                let address = data_block["activity_address"] as! String
                                let activityTime = data_block["activity_time"] as! String
                                //let postTime = data_block["post_time"] as? String
                                let duration = data_block["activity_duration"] as! String
                                let phone = data_block["phone_number"] as? String
                                let detail = data_block["activity_detail"] as! String
                                let activityType = data_block["activity_type"] as? String
                                let city = data_block["city"] as! String
                                let state = data_block["state"] as? String
                                let imageName = data_block["image_name"] as? String
                                let eventCreator = data_block["event_creator"] as? String
                                
                                let event:Event = Event(id:id, title:title, eventType:activityType!)!
                                
                                if (imageName != nil && imageName != "NULL"){
                                    event.imageName = imageName!
                                    event.thumbImageName = imageName!
                                }
                                event.city = city ?? ""
                                event.description = description ?? ""
                                event.duration = duration ?? ""
                                event.phoneNumber = phone ?? ""
                                event.description = detail ?? ""
                                event.eventTime = activityTime ?? ""
                                event.location = address ?? ""
                                event.eventType = activityType ?? ""
                                event.eventCreator = eventCreator ?? ""
                                event.state = state ?? ""
                                
                                publishedEvents.append(event)
                                
                            }
                }
                
                do_publishedEvents_section_refresh()
                
            }
            
            
        }
        catch let error as NSError {
            print("json error: \(error)")
        }
    }
    
    func do_publishedEvents_section_refresh(){
        self.eventsTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        return
    }

    
    // for download image from server
    func getImageFromServer(imageName: String, imageView: UIImageView, folder: String, flag: Int){
        
        if (!imageName.isEmpty && imageName != "NULL")
        {
            let imageUrl = "\(serverUrl)imgupload/\(folder)/\(imageName)"
            
            let url = NSURL(string: imageUrl)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, _, error) -> Void in
                // make round image
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    imageView.image = image
                    //imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    if (flag == 0){
                    imageView.layer.borderWidth = 1
                    imageView.layer.masksToBounds = false
                    imageView.layer.borderColor = UIColor.blackColor().CGColor
                    imageView.layer.cornerRadius = imageView.frame.height/2
                    imageView.clipsToBounds = true
                    }
                    else{
                        imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    }
                    imageView.layoutSubviews()
                    
                }
            }).resume()
        }
        
    }


    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return joinedEvents.count
        }
        else if (section == 1){
            return publishedEvents.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventTableViewCell", forIndexPath: indexPath) as! EventTableViewCell
        
        var imageName = "" as String
        
        if (indexPath.section == 0){
            if joinedEvents.count > 0{
                let event = joinedEvents[indexPath.row]
                cell.titleLabel.text = event.title ?? ""
                cell.timeLabel.text = event.eventTime ?? ""
                if (event.city.isEmpty){
                    cell.locationLabel.text = "Abroad"
                }else{
                    cell.locationLabel.text = event.city
                }
                
                imageName = event.thumbImageName ?? ""
                if (!imageName.isEmpty){
                    getImageFromServer(imageName, imageView: cell.profileImageView, folder: "activity_thumb_image", flag: 1)
                }
            }
        }
        else if (indexPath.section == 1){
            if publishedEvents.count > 0{
                let event = publishedEvents[indexPath.row]
                cell.titleLabel.text = event.title ?? ""
                cell.timeLabel.text = event.eventTime ?? ""
                if (event.city.isEmpty){
                    cell.locationLabel.text = "Abroad"
                }else{
                    cell.locationLabel.text = event.city
                }
                
                imageName = event.thumbImageName ?? ""
                if (!imageName.isEmpty){
                    getImageFromServer(imageName, imageView: cell.profileImageView, folder: "activity_thumb_image", flag: 1)
                }
            }
        }

        

        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Joined Events"
        }
        else if (section == 1){
            return "Published Events"
        }
        
        return ""
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
