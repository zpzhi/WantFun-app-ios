//
//  FollowingUsersTableViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 12/11/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class FollowingUsersTableViewController: UITableViewController {
    
    // MARK: Properties
    @IBOutlet var tableview: UITableView!
    
    
    var followingdUsers:Array< User > = Array < User >()
    let serverUrl = "http://meetup.wcpsjshxnna.com/meetup-web/"
    let loginUser = "test"

    override func viewDidLoad() {
        super.viewDidLoad()

       self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        get_followingUserDetail_from_url("\(serverUrl)get-user-friends.php")
    }
    
    // MARK: connect with server and fetch data
    func get_followingUserDetail_from_url(url:String)
    {
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let postString = "username=\(loginUser)"
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
                    self.followingdUsers.removeAll()
                    self.do_tableview_refresh()
                }
                return
            })
            
        }
        
        task.resume()
        
    }
    
    func extract_json_join(data:NSString)
    {
        followingdUsers.removeAll()
        let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let json: AnyObject?
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
            if let items = json!["friends_info"] as? NSArray {
                
                for item in items
                {
                    if let innerArray = item as? NSArray{
                        for iner_item in innerArray{
                            if let data_block = iner_item as? NSDictionary
                            {
                                let image = data_block["image_name"] as? String
                                let realName = data_block["name"] as? String
                                let phoneNumber = data_block["phone_number"] as? String
                                let userDescription = data_block["user_description"] as? String
                                
                                let id = data_block["id_user"] as! String
                                let username = data_block["username"] as! String
                                let thumb = data_block["image_thumb"] as? String
                                
                                let user = User(id: id)!
                                user.name = username ?? ""
                                user.phoneNumber = phoneNumber ?? ""
                                user.realName = realName ?? ""
                                user.description = userDescription ?? ""
                                user.phoneNumber = phoneNumber ?? ""
                                if (thumb != nil && thumb != "NULL"){
                                    user.photoName = image!
                                    user.thumbnailName = thumb!
                                }
                                followingdUsers.append(user)
                                
                            }
                        }
                    }
                }
            }
            self.do_tableview_refresh()
            
            
        }
        catch let error as NSError {
            print("json error: \(error)")
        }
    }
    
    func do_tableview_refresh(){
        dispatch_async(dispatch_get_main_queue(), {
            self.tableview.reloadData()
            return
        })
    }

    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingdUsers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
        
        var imageName = "" as String
        if followingdUsers.count > 0{
            let user = followingdUsers[indexPath.row]
            cell.followingUserName.text = user.name ?? ""
            imageName = user.thumbnailName ?? ""
            if (!imageName.isEmpty){
                getImageFromServer(imageName, imageView: cell.followingUserThumbImageView)
            }
        }
        
        if (imageName.isEmpty){
            let image = UIImage(named: "defaultUser")!
            let cellImageLayer: CALayer?  = cell.followingUserThumbImageView.layer
            cellImageLayer!.cornerRadius = cell.followingUserThumbImageView.frame.size.width/2
            cellImageLayer!.masksToBounds = true
            cell.followingUserThumbImageView.image = image
        }

        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nav = segue.destinationViewController as! UINavigationController
        let destinationVC = nav.topViewController as! ProfileTableViewController
        
        let row = self.tableView.indexPathForSelectedRow!.row
        destinationVC.profileDetail = followingdUsers[row]
        
    }
    

}
