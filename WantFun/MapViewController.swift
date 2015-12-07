//
//  MapViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 11/26/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UISearchBarDelegate,
 CLLocationManagerDelegate, MKMapViewDelegate{

    // Mark: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationAddressLabel: UILabel!
    
    var passedAddress : String = ""
   
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var locationManager : CLLocationManager!
    var currentLocation: Array< String > = Array< String >()
    var locationString : String = ""
    var lastAnnotation = MKPointAnnotation()
    var addressFromMap :CLPlacemark?

    // Mark: Actions
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Began {
            if sender.state != UIGestureRecognizerState.Began { return }
            let touchLocation = sender.locationInView(mapView)
            let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationCoordinate
            
            getAddressFromLocation(locationCoordinate.latitude, longitude: locationCoordinate.longitude, annotation: annotation)
        
            // clear last annotations
            if (self.mapView.annotations.count > 0){
                // remove last search annotation
                if self.pointAnnotation != nil{
                    self.mapView.removeAnnotation(self.pointAnnotation)
                }
                // remove last long pressed annotation point
                if (self.mapView.annotations.count > 0){
                    self.mapView.removeAnnotation(self.lastAnnotation)
                }
            }
            
            self.mapView.addAnnotation(annotation)
            self.lastAnnotation = annotation
            
        }
        
    }
    
    
    // Mark: Navigation
    @IBAction func backToEventlist(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Init the zoom level
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let latDelta = 0.1
        let longDelta = 0.1
        let currentLocationSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationManager.location!.coordinate.latitude, locationManager.location!.coordinate.longitude)
        let currentRegion: MKCoordinateRegion = MKCoordinateRegionMake(currentLocation, currentLocationSpan)
        
        mapView.setRegion(currentRegion, animated: true)

        
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
        
        locationAddressLabel.text = passedAddress

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if self.mapView.annotations.count != 0{
            // remove last search location point
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
            // remove annotation point from long pressed
            if (self.mapView.annotations.count > 0){
                self.mapView.removeAnnotation(lastAnnotation)
            }
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            self.getAddressFromLocation(self.pointAnnotation.coordinate.latitude, longitude: self.pointAnnotation.coordinate.longitude, annotation: self.pointAnnotation)
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    
    func getAddressFromLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, annotation: MKPointAnnotation){
        
        currentLocation.removeAll()

        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error  \(error!.localizedDescription)")
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                self.addressFromMap = pm

                let street = pm.thoroughfare as String?
                if street != nil{
                    self.currentLocation.append(street!)
                }
                
                let zip = pm.postalCode as String?
                if zip != nil{
                    self.currentLocation.append(zip!)
                }
                
                let city =  pm.locality as String?
                if city != nil{
                    self.currentLocation.append(city!)
                }

                let province = pm.administrativeArea as String?
                if province != nil{
                    self.currentLocation.append(province!)
                }

                // Add Country
                let country = pm.country
                if country != nil{
                    self.currentLocation.append(country!)
                }
                
                self.locationString = self.currentLocation.joinWithSeparator(" ")
                self.locationAddressLabel.text = self.locationString
                
            }
            else {
                annotation.title = "Unknown Place"
            }
            
        })
    }
   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
