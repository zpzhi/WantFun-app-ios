//
//  RegisterTableViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 12/15/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class RegisterTableViewController: UITableViewController {
    
    // Mark: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var comfirmPasswordTextField: UITextField!
    
    let serverUrl = "http://meetup.wcpsjshxnna.com/meetup-web/"
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

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
    
    // Mark: Actions
    @IBAction func back(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func signUp(sender: UIButton) {
        prepareSignUp()
    }
    
    @IBAction func signUpFromBarItem(sender: UIBarButtonItem) {
        prepareSignUp()
    }
    
    
    func prepareSignUp(){
        let username:NSString = usernameTextField.text!
        let email:NSString = emailTextField.text!
        let password:NSString = passwordTextField.text!
        let comfirmPassword:NSString = comfirmPasswordTextField.text!
        let alert = UIAlertController(title: "Sign up Failed!", message:"", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        
        if ( username.isEqualToString("") || email.isEqualToString("") || password.isEqualToString("") || comfirmPassword.isEqualToString("")){
                alert.message = "Please input all the fileds"
                self.presentViewController(alert, animated: true){}
                
        } else if !email.containsString("@"){
            alert.message = "Not a valid email address"
            self.presentViewController(alert, animated: true){}
            
        } else if !password.isEqualToString(comfirmPassword as String){
            alert.message = "Password not the same as comfirmed"
            
        }
        else {
            signUpAction(email, username: username, password: password, url: "\(serverUrl)register-meetup.php")
        }
    }
    
    func signUpAction(email:NSString, username:NSString, password:NSString, url:String){
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let postString:NSString = "email=\(email)&password=\(password)&username=\(username)&imgSelectedStatus=0"
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
                print (json)
                self.extract_json(json!)
            })
            
        }
        
        task.resume()
    }
    
    func extract_json(json: NSString){
        if (json.containsString("&&asb##")){
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let loginDetail = json.componentsSeparatedByString("&&asb##")
            let userid: String? = loginDetail[1]
            prefs.setObject(self.usernameTextField.text, forKey: "USERNAME")
            prefs.setObject(userid, forKey: "USERID")
            prefs.setInteger(1, forKey: "ISLOGGEDIN")
            prefs.synchronize()
            
            self.performSegueWithIdentifier("showAllEvents", sender: self)
            
        }else {
            var alert: UIAlertController?
            if (json.containsString("This email is already")){
                alert = UIAlertController(title: "Sign Up Failed!", message:"This email has been registered", preferredStyle: .Alert)
            }
            else if (json.containsString("This UserName is already")){
                alert = UIAlertController(title: "Sign Up Failed!", message:"This username has been registered", preferredStyle: .Alert)
                
            }
            if (alert != nil){
                alert!.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                self.presentViewController(alert!, animated: true){}
            }
            
        }
    }

    
    

}
