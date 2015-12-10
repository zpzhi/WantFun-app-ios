
//
//  AddEventViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 11/27/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBookUI

class AddEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    // MARK: Properties
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var durationTimeTextField: UITextField!
    @IBOutlet weak var datePicker: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var provincePickerTextField: UITextField!
    @IBOutlet weak var cityPickerTextField: UITextField!
    @IBOutlet weak var detailAddressTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let serverUrl = "http://meetup.wcpsjshxnna.com/meetup-web/"
    var pickOption = ["北京", "天津", "上海", "重庆", "河北", "山西", "台湾", "辽宁", "吉林", "黑龙江", "江苏", "浙江", "安徽", "福建","江西", "山东", "河南", "湖北", "湖南", "广东", "甘肃", "四川", "贵州","海南", "云南", "青海", "陕西", "广西", "西藏","宁夏", "新疆", "内蒙", "澳门", "香港", "海外"]
    var cityPickOption:Array< String > = Array< String >()
    let locationManager = CLLocationManager()
    var currentLocation: Array< String > = Array< String >()
    var locationString : String = ""
    
    var addressFromMap :CLPlacemark?
    let imagePickerController = UIImagePickerController()
    var selectedImage :UIImage?
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocation()
        setDefaultDatePickerTextField()
        setDescriptionFieldBoarder()
        disableCityPickerTextFieldAtBeginning()
        
        eventTitleTextField.delegate = self
        durationTimeTextField.delegate = self
        phoneNumberTextField.delegate = self
        detailAddressTextField.delegate = self
        
        checkValidMealName()

    }
    
    override func viewDidAppear(animated: Bool) {
        if (addressFromMap != nil){
            self.updateLocationInfoFromMap(addressFromMap!)
        }

    }
    
    func setDefaultDatePickerTextField(){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeString = dateFormatter.stringFromDate(NSDate())
        self.datePicker.text = timeString
    }
    
    func setDescriptionFieldBoarder(){
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        self.descriptionTextView.layer.borderWidth = 0.5
        self.descriptionTextView.layer.borderColor = borderColor.CGColor
        self.descriptionTextView.layer.cornerRadius = 5.0
    }
    
    func disableCityPickerTextFieldAtBeginning(){
        self.cityPickerTextField.userInteractionEnabled = false
        self.cityPickerTextField.enabled = false

    }
    
    func updateLocationInfoFromMap(placemark: CLPlacemark){
        
        if (placemark.country != "中国" && placemark.country!.caseInsensitiveCompare("China") != NSComparisonResult.OrderedSame){
            self.provincePickerTextField.text = self.pickOption.last
            
            let address = ABCreateStringWithAddressDictionary(placemark.addressDictionary!, false);
            
            self.detailAddressTextField.text = address
        
        }
        else{
            if placemark.administrativeArea != nil && self.pickOption.contains(placemark.administrativeArea!){
                provincePickerTextField.text = placemark.administrativeArea
                
                cityPickerTextField.userInteractionEnabled = true
                cityPickerTextField.enabled = true
                get_cityList_from_url("\(serverUrl)get-cities.php")
                
                if placemark.locality != nil && self.cityPickOption.contains(placemark.locality!){
                    cityPickerTextField.text = placemark.locality
                }
            }
            
            if placemark.subLocality != nil{
                detailAddressTextField.text = placemark.subLocality
            }
            
            else if placemark.thoroughfare != nil{
                detailAddressTextField.text = detailAddressTextField.text! + placemark.thoroughfare!
            }
            else if placemark.subThoroughfare != nil{
                detailAddressTextField.text = detailAddressTextField.text! + placemark.subThoroughfare!
            }
            else{
                detailAddressTextField.text = ""
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
        
        
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        
        // Setup the buttons to be put in the system.
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        textField.inputAccessoryView = keyboardDoneButtonView
    }
    
    func checkValidMealName() {
        // Disable the Save button if any necessary text fields are empty.
        let title = eventTitleTextField.text ?? ""
        let duration = durationTimeTextField.text ?? ""
        let phone = phoneNumberTextField.text ?? ""
        let province = provincePickerTextField.text ?? ""
        let detailAddr = detailAddressTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        
        if province == "海外"{
            saveButton.enabled = !title.isEmpty && !duration.isEmpty && !phone.isEmpty && !detailAddr.isEmpty && !description.isEmpty
        }else{
            let city = cityPickerTextField.text ?? ""
            saveButton.enabled = !title.isEmpty && !duration.isEmpty && !phone.isEmpty && !province.isEmpty && !city.isEmpty && !detailAddr.isEmpty && !description.isEmpty
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.resignFirstResponder()
        checkValidMealName()
    }
    
    func endEditingNow(){
        self.view.endEditing(true)
    }
    
   
    // MARK: Action
    
    func getLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            
            // Location name
            //let locationName = placeMark.addressDictionary?["Name"] as? NSString
            // Street address
            let street = placeMark.addressDictionary?["Thoroughfare"] as? String
            self.currentLocation.append(street!)
            // City
            let city = placeMark.addressDictionary?["City"] as? String
            self.currentLocation.append(city!)
            // Zip code
            let zip = placeMark.addressDictionary?["ZIP"] as? String
            self.currentLocation.append(zip!)
            // Country
            let country = placeMark.addressDictionary?["Country"] as? String
            self.currentLocation.append(country!)
            
            
            if (self.currentLocation.last != "中国" && self.currentLocation.last!.caseInsensitiveCompare("China") != NSComparisonResult.OrderedSame){
                self.provincePickerTextField.text = self.pickOption.last
                
                self.locationString = self.currentLocation.joinWithSeparator(" ")
                self.detailAddressTextField.text = self.locationString
            }
            else{
                self.provincePickerTextField.text = self.pickOption[0]
                self.cityPickerTextField.text = self.pickOption[0]
            }
            
        })
        
    }
    
    @IBAction func dateTimeInputPressed(sender: UITextField) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        
        
        let datePickerView  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 40, 0, 0))
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        datePickerView.minuteInterval = 5
        
        inputView.addSubview(datePickerView) // add date picker to UIView
        
        let doneButton =  createButton()
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        
        sender.inputView = inputView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        
        handleDatePicker(datePickerView) // Set the date on start.
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        datePicker.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func doneButton(sender:UIButton?)
    {
        datePicker.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    @IBAction func provinceInputPressed(sender: UITextField) {
        
        cityPickerTextField.userInteractionEnabled = false
        cityPickerTextField.enabled = false
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.tag = 1
        inputView.addSubview(pickerView)
        let doneButton1 = createButton()
        inputView.addSubview(doneButton1) // add Button to UIView
        
        doneButton1.addTarget(self, action: "doneButton1:", forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        
        provincePickerTextField.inputView = inputView

    }
    
    func doneButton1(sender:UIButton?)
    {
        provincePickerTextField.resignFirstResponder() // To resign the inputView on clicking done.
        detailAddressTextField.text = ""
        
        let province:String = provincePickerTextField.text!
        
        if province == "海外"{
            cityPickerTextField.text = ""
            cityPickerTextField.userInteractionEnabled = false
            cityPickerTextField.enabled = false
        }
        else{
            cityPickerTextField.userInteractionEnabled = true
            cityPickerTextField.enabled = true
            get_cityList_from_url("\(serverUrl)get-cities.php")
        }
        
    }
    
    func get_cityList_from_url(url:String)
    {
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let province:String = provincePickerTextField.text!
        let postString = "province=\(province)"
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
        cityPickOption.removeAll()
        let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let json: AnyObject?
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
            if let items = json!["cities_info"] as? NSArray {
                for item in items
                {
                    if let data_block = item as? NSDictionary
                    {
                        let city = data_block["city"] as! String
                        cityPickOption.append(city)
                    }
                }
            }
            
            cityPickerTextField.text = cityPickOption[0]
        }
        catch let error as NSError {
            print("json error: \(error)")
        }
    }

    @IBAction func cityInputPressed(sender: UITextField) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        let cityPickerView = UIPickerView()
        cityPickerView.delegate = self
        cityPickerView.tag = 2
        inputView.addSubview(cityPickerView)
        
        let doneButton2 = createButton()
        inputView.addSubview(doneButton2) // add Button to UIView
        
        doneButton2.addTarget(self, action: "doneButton2:", forControlEvents: UIControlEvents.TouchUpInside) // set button click event

        cityPickerTextField.inputView = inputView

    }
    
    func doneButton2(sender:UIButton?)
    {
        cityPickerTextField.resignFirstResponder() // To resign the inputView on clicking done.
    }
    
    func createButton() -> UIButton {
        let button = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), 0, 100, 50))
        button.setTitle("Done", forState: UIControlState.Normal)
        button.setTitle("Done", forState: UIControlState.Highlighted)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        return button

    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1){
            return pickOption.count
        }else{
            return cityPickOption.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1){
            return pickOption[row]
        }else{
            return cityPickOption[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1){
            provincePickerTextField.text = pickOption[row]
        }else{
            cityPickerTextField.text = cityPickOption[row]
        }
    }
    
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        descriptionTextView.resignFirstResponder()
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(imagePickerController, animated: true, completion: nil)
        }
        else
        {
            let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    
    func openGallary()
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    //PickerView Delegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        selectedImage=info[UIImagePickerControllerOriginalImage] as? UIImage
        //selectedImage = Helper.rotateCameraImageToProperOrientation(selectedImage!, maxResolution: 320)
        selectedImage = UIImage(CGImage: selectedImage!.CGImage!, scale: 1, orientation: selectedImage!.imageOrientation)
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
      
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Segue Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMapSegue"
        {
            //if let destinationVC = segue.destinationViewController as? MapViewController{
            //    destinationVC.passedAddress = locationString
            //}
            
            let nav = segue.destinationViewController as! UINavigationController
            let destinationVC = nav.topViewController as! MapViewController
            
            destinationVC.passedAddress = locationString
        }
        
        if saveButton === sender {
            
            postEventToServer("\(serverUrl)post-event.php")
        }
    }
    
    func postEventToServer(url:String)
    {
        // encode image
        var base64String : String = ""
        if (selectedImage != nil){
            let size = CGSizeApplyAffineTransform(selectedImage!.size, CGAffineTransformMakeScale(0.3, 0.3))
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            selectedImage!.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let imageData = UIImageJPEGRepresentation(scaledImage, 0.9)
            base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) // encode the image
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let postTime = dateFormatter.stringFromDate(NSDate())
        
        var params = "easonlove=easonlove&loginUserId=10"
        params = params + "&activityTime=" + datePicker.text!
        params = params + ":00"
        params = params + "&postTime=" + postTime
        params = params + "&title=" + eventTitleTextField.text!
        params = params + "&duration=" + durationTimeTextField.text!
        params = params + "&province=" + provincePickerTextField.text!
        params = params + "&city=" + cityPickerTextField.text! ?? ""
        params = params + "&address=" + detailAddressTextField.text!
        params = params + "&description=" + descriptionTextView.text!
        params = params + "&phoneNumber=" + phoneNumberTextField.text!
        params = params + "&activityType=1"
        
        if (!base64String.isEmpty){
            params = params + "&filename=anyname.jpg"
            let imageString = base64String.stringByAddingPercentEncodingForURLQueryValue()!
            params = params + "&imageString=" + imageString
        }

        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let postString = params
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
                //let json = NSString(data: data!, encoding: NSASCIIStringEncoding)
                //self.extract_json(json!)
                return
            })
            
        }
        
        task.resume()
        
    }
    

    @IBAction func unwindToAddEventViewControllerWired(unwindSegue: UIStoryboardSegue) {
        if let mapViewController = unwindSegue.sourceViewController as? MapViewController {
            
            self.addressFromMap = mapViewController.addressFromMap!
        }
    }

}

extension String {
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~")
        
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
}
