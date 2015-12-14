//
//  LoginTableViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 12/14/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {
    
    // Mark: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let serverUrl = "http://meetup.wcpsjshxnna.com/meetup-web/"
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("loginCell1", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
    
    // MARK: Actions
    @IBAction func back(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginFromBarItem(sender: UIBarButtonItem) {
        prepareLogin()
    }

    @IBAction func login(sender: UIButton) {
        prepareLogin()
    }
    
    func prepareLogin(){
        let username:NSString = emailTextField.text!
        let password:NSString = passwordTextField.text!
        
        if ( username.isEqualToString("") || password.isEqualToString("") ) {
            let alert = UIAlertController(title: "Sign in Failed!", message:"Please enter Email and Password", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        } else if !username.containsString("@"){
            let alert = UIAlertController(title: "Sign in Failed!", message:"Not a valid email address", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            
        }else {
            loginAction(username, password: password, url: "\(serverUrl)login-meetup.php")
        }
    }
    
    func loginAction(email:NSString, password:NSString, url:String){
 
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let postString:NSString = "email=\(email)&password=\(password)"
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
            })
            
        }
        
        task.resume()
    }
    
    func extract_json(json: NSString){
        if (json.containsString("&&asb##")){
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let loginDetail = json.componentsSeparatedByString("&&asb##")
            let username: String = loginDetail[0]
            let userid: String? = loginDetail[1]
            prefs.setObject(username, forKey: "USERNAME")
            prefs.setObject(userid, forKey: "USERID")
            prefs.setInteger(1, forKey: "ISLOGGEDIN")
            prefs.synchronize()
            
            print ("username is \(username)")
            
            self.performSegueWithIdentifier("showAllEvents", sender: self)
            
        }else {
            var alert: UIAlertController?
            if (json == "error 1"){
                alert = UIAlertController(title: "Sign in Failed!", message:"No such email address", preferredStyle: .Alert)
                            }
            else if (json == "error 2"){
                alert = UIAlertController(title: "Sign in Failed!", message:"Wrong password for this email", preferredStyle: .Alert)
               
            }
            if (alert != nil){
                alert!.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                self.presentViewController(alert!, animated: true){}
            }

        }
    }

}
