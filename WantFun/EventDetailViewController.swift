//
//  EventDetailViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 12/8/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class EventDetailViewController: UITableViewController {
    
    //MARK: Properties
    
    @IBOutlet var eventDetailTableView: UITableView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDuration: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var joinButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    var selectedEvent : Event?
    let serverUrl = "http://meetup.wcpsjshxnna.com/meetup-web/"
    var eventCreator: String?
    var hostUser : User?
    let loginUserId = "11"
    var joinedUsers:Array< User > = Array < User >()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadEventFromPassData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadEventFromPassData(){
        if selectedEvent != nil{
            eventTitle.text = selectedEvent?.title
            eventTime.text = selectedEvent?.eventTime
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let eventDate = dateFormatter.dateFromString(eventTime.text!)! as NSDate
        
            let currentDate : NSDate = NSDate()
            
            let compareResult = currentDate.compare(eventDate)
            if compareResult == NSComparisonResult.OrderedDescending {
                joinButton.title = ""
                joinButton.enabled = false
            }
            
            let state = selectedEvent?.state
            var location = selectedEvent?.location
            if state != "海外"{
                let city = selectedEvent?.city ?? ""
                location = "\(state!)\(city)\(location!)"
            }
            
            eventLocation.text = location
            eventDuration.text = selectedEvent?.duration
            eventDescription.text = selectedEvent?.description
            eventCreator = selectedEvent?.eventCreator
            
            if (eventCreator == loginUserId){
                joinButton.title = ""
                joinButton.enabled = false
            }
            
            get_eventCreatorDetail_from_url("\(serverUrl)get-user-detail-by-id.php")
            get_eventJoinUserDetail_from_url("\(serverUrl)get-user-images-names.php", id: (selectedEvent?.id)!)
            
            
            
            var image:UIImage?
            if (selectedEvent!.imageName == nil || selectedEvent!.imageName == "")
            {
                if selectedEvent!.eventType == "0"{
                    image = UIImage(named: "festivalSample")!
                }
                else if selectedEvent!.eventType == "1" {
                    image = UIImage(named: "boardGameSample")!
                }
                else if selectedEvent!.eventType == "2" {
                    image = UIImage(named: "prisonBreakSample")!
                }
                else if selectedEvent!.eventType == "3" {
                    image = UIImage(named: "exhibitionSample")!
                }
                else if selectedEvent!.eventType == "4" {
                    image = UIImage(named: "startupLectureSample")!
                }
                else if selectedEvent!.eventType == "5" {
                    image = UIImage(named: "movieWatchingSample")!
                }
                else if selectedEvent!.eventType == "6" {
                    image = UIImage(named: "sportsSample")!
                }
                else if selectedEvent!.eventType == "7" {
                    image = UIImage(named: "travelSample")!
                }
                else {
                    image = UIImage(named: "otherEventSample")!
                }
                
                imageView!.image = image
                
            }
            else
            {
                let imageName = (selectedEvent!.imageName)!
                let imageUrl = "\(serverUrl)imgupload/activity_image/\(imageName)"
                
                let url = NSURL(string: imageUrl)
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, _, error) -> Void in
                    
                    let image = UIImage(data: data!)
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.imageView!.image = image
                        self.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
                        self.imageView!.layoutSubviews()
                    }
                }).resume()
                
            }
            
        }

    }
    
    // MARK: Communcation with Server
    func get_eventCreatorDetail_from_url(url:String)
    {
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let postString = "eventCreatorId=\(eventCreator!)"
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
                        
                        hostUser = User(id: id)!
                        hostUser!.name = username ?? ""
                        if (thumb != nil && thumb != "NULL"){
                            hostUser?.photoName = thumb!
                            hostUser?.thumbnailName = thumb!
                        }
                        
                    }
                }
                
                do_hostUsers_section_refresh()
            }
            
            
        }
        catch let error as NSError {
            print("json error: \(error)")
        }
    }
    
    func get_eventJoinUserDetail_from_url(url:String, id:String)
    {
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let postString = "id=\(id)"
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
                else{
                    self.joinedUsers.removeAll()
                    self.joinButton.title = "Join"
                    self.do_joinUsers_section_refresh()
                }
                return
            })
            
        }
        
        task.resume()
        
    }
    
    func extract_json_join(data:NSString)
    {
        joinedUsers.removeAll()
        let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let json: AnyObject?
        var flag = 0
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
            if let items = json!["user_info"] as? NSArray {
                
                for item in items
                {
                    if let innerArray = item as? NSArray{
                    for iner_item in innerArray{
                    if let data_block = iner_item as? NSDictionary
                    {
                        let id = data_block["id_user"] as! String
                        let username = data_block["username"] as! String
                        let thumb = data_block["image_thumb"] as? String
                        
                        let user = User(id: id)!
                        user.name = username ?? ""
                        if (thumb != nil && thumb != "NULL"){
                            user.photoName = thumb!
                            user.thumbnailName = thumb!
                        }
                        joinedUsers.append(user)
                        
                        if (id == loginUserId){
                            flag = 1
                        }
                        
                    }
                    }
                    }
                }
                
                do_joinUsers_section_refresh()
            }
            
            
        }
        catch let error as NSError {
            print("json error: \(error)")
        }
        
        if (flag == 1){
            joinButton.title = "Unjoin"
        }else{
            joinButton.title = "Join"
        }
    }

    
    func do_hostUsers_section_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.eventDetailTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            return
        })
    }
    
    func do_joinUsers_section_refresh(){
        self.eventDetailTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        return
    }
    
    // for download image from server
    func getImageFromServer(imageName: String, imageView: UIImageView){
        
        if (!imageName.isEmpty && imageName != "NULL")
        {
            let imageUrl = "\(serverUrl)imgupload/user_thumb_image/\(imageName)"
            
            let url = NSURL(string: imageUrl)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, _, error) -> Void in
                // make round image
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    imageView.image = image
                    //imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    imageView.layer.borderWidth = 1
                    imageView.layer.masksToBounds = false
                    imageView.layer.borderColor = UIColor.blackColor().CGColor
                    imageView.layer.cornerRadius = imageView.frame.height/2
                    imageView.clipsToBounds = true
                    imageView.layoutSubviews()
                    
                }
            }).resume()
        }

    }
    
    func joinEvent(url:String, eventId: String, userId: String){
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let postString = "userId=\(userId)&eventID=\(eventId)&uaDescription="
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
                
                if (json != nil && json == "success"){
                    print ("Successfully join this event")
                    self.get_eventJoinUserDetail_from_url("\(self.serverUrl)get-user-images-names.php", id: (self.selectedEvent?.id)!)
                    
                }
                return
            })
            
        }
        
        task.resume()
    }
    
    func unjoinEvent(url:String, eventId: String, userId: String){
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let postString = "userId=\(userId)&eventID=\(eventId)"
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
                
                if (json != nil && json == "success"){
                    print ("Successfully unjoin this event")
                    self.get_eventJoinUserDetail_from_url("\(self.serverUrl)get-user-images-names.php", id: (self.selectedEvent?.id)!)
                    
                }
                return
            })
            
        }
        
        task.resume()
    }


    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 1
        }
        else if (section == 1){
            return joinedUsers.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
        
        var imageName = "" as String
        
        if (indexPath.section == 0){
            if (hostUser != nil){
                cell.userName.text = hostUser!.name ?? ""
                
                
                imageName = hostUser!.thumbnailName ?? ""
                if (!imageName.isEmpty){
                    getImageFromServer(imageName, imageView: cell.thumbUserImageView)
                }
            }
        }
        else
        {
            if joinedUsers.count > 0{
            let user = joinedUsers[indexPath.row]
                cell.userName.text = user.name ?? ""
                imageName = user.thumbnailName ?? ""
                if (!imageName.isEmpty){
                    getImageFromServer(imageName, imageView: cell.thumbUserImageView)
                }
            }
            
        }
        
        if (imageName.isEmpty){
            let image = UIImage(named: "defaultUser")!
            let cellImageLayer: CALayer?  = cell.thumbUserImageView.layer
            cellImageLayer!.cornerRadius = cell.thumbUserImageView.frame.size.width/2
            cellImageLayer!.masksToBounds = true
            cell.thumbUserImageView.image = image
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Host"
        }
        else if (section == 1){
            return "Joined User"
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
    
    //MARK: Action
    
    @IBAction func joinThisEvent(sender: UIBarButtonItem) {
        //hard code for login user
        if (joinButton.title == "Join"){
            joinEvent("\(serverUrl)join-event.php", eventId: (selectedEvent?.id)!, userId: loginUserId)
        }else if(joinButton.title == "Unjoin"){
            unjoinEvent("\(serverUrl)unjoin-event.php", eventId: (selectedEvent?.id)!, userId: loginUserId)
        }
    }
    



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender === backButton{
            
        }
    }


}
