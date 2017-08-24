//
//  EventMapViewController.swift
//  Weav
//
//  Created by SAMEER SURESH on 4/2/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class EventMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var current_location: CLLocation!
    var colorSwitcher = 0
    var Color = UIColor()
    var name_to_submit_on_click: String!
    var id_to_time = [String:NSDate]()
    var endtime_to_submit_on_click: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        //Check the current status
        if CLLocationManager.authorizationStatus() == .NotDetermined
        {
            //If the status is not determined, request it for use within the app
            locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        //Authorized for us to use location
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            
            //Now we call start updating location
            manager.startUpdatingLocation()
        }
            
        else {
            
            let alertVC = UIAlertController(title: "Geolocation not enabled", message: "You need to enable Geolocation for this app in Settings to use this feature.", preferredStyle: .ActionSheet)
            alertVC.addAction(UIAlertAction(title: "Open Settings", style: .Default) { value in
                print("tapped default button")
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                })
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(alertVC, animated: true, completion: nil)
            
            
        }
        
    }
    
    func changeColor(){
        if(colorSwitcher == 0){
            Color = UIColor.orangeColor()
            colorSwitcher = 1
        }
            
        else if(colorSwitcher == 1){
            Color = UIColor.cyanColor()
            colorSwitcher = 2
        }
        else if(colorSwitcher == 2){
            Color = UIColor.redColor()
            colorSwitcher = 0
        }
    }
    
    func queryParse(){
        let query = PFQuery(className:"events")
        do {
            let objects = try query.findObjects()
            for obj in objects{
                let loc = obj["location"] as! PFGeoPoint
                let latitude: CLLocationDegrees = loc.latitude
                let longitude: CLLocationDegrees = loc.longitude
                let location: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
                let dist = (current_location.distanceFromLocation(location)/1000)/1.60934
                if(dist < 15){
                    let et = obj["endTime"] as! NSDate
                    self.id_to_time[obj.objectId!] = et
                    let currentDate = NSDate()
                    if (et.isGreaterThanDate(currentDate)) {
                        let overlay = Weav(title: obj["eventName"] as! String, locationName: obj.objectId!, discipline: colorSwitcher, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), eventID: obj.objectId! as String)
                        self.mapView.addAnnotation(overlay)
                        addRadiusOverlayForWeav(overlay, radi: 100)
                    }
                }
            }
        } catch {
            print("error!")
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //var view = MKPinAnnotationView()
        if let annotation = annotation as? Weav {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                view.pinTintColor = Color
                changeColor()
            }
            return view
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            changeColor()
            circleRenderer.lineWidth = 1.0
            //circleRenderer.strokeColor = UIColor.lightGrayColor()
            circleRenderer.fillColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.25)
            return circleRenderer
        }
        return nil
    }
    //, radi: Double
    func addRadiusOverlayForWeav(center: Weav, radi: CLLocationDistance) {
        mapView?.addOverlay(MKCircle(centerCoordinate: center.coordinate, radius: radi))
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let weev = annotationView.annotation!
            //self.name_to_submit_on_click = weev.title!
            //self.endtime_to_submit_on_click = self.id_to_time
            performSegueWithIdentifier("mapsToCollection", sender: weev)
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "mapsToCollection"){
            let vc = segue.destinationViewController as! WeavCollectionViewController
            let weev = sender as! Weav
            vc.eventID = weev.eventID
//            vc.eventName = weev.title
//            vc.endTime = self.id_to_time[weev.eventID]
            vc.current_location = self.current_location
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        current_location = locations.last
        let center = CLLocationCoordinate2D(latitude: current_location!.coordinate.latitude, longitude: current_location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
        queryParse()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }


    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
