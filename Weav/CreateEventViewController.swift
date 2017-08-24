//
//  CreateEventViewController.swift
//  Weav
//
//  Created by Jesmin Ngo on 4/25/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import Parse
import UIKit
import MapKit
import CoreLocation
import MBProgressHUD

protocol CreateEventsViewControllerDelegate {
    func createEventsViewControllerDidSelect(value: String)
}

extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}


class CreateEventsViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var EndTimeDatePickerConstraint: NSLayoutConstraint!
    @IBOutlet weak var CreateEventXConstraint: NSLayoutConstraint!
    @IBOutlet weak var EndTimeTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var EventEndTimeLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var EventEndTime: UILabel!
    @IBOutlet weak var jarEndTime: UIDatePicker!
    @IBOutlet weak var jarName: UITextField!
    
    var fromUsePhoto: Bool = false
    var photoToSubmit: UIImage!
    var eventIDToSubmit: String!
    var caption: String = ""
    var delegate : CreateEventsViewControllerDelegate?
    
    let locationManager = CLLocationManager()
    var pickerData: [String] = [String]()
    
    /*ANIMATIONS OCCUR HERE*/
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")

        CreateEventXConstraint.constant -= view.bounds.width
        EndTimeDatePickerConstraint.constant -= view.bounds.width
        EndTimeTextFieldConstraint.constant -= view.bounds.width
        EventEndTimeLabelConstraint.constant -= view.bounds.width
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.CreateEventXConstraint.constant += self.view.bounds.width
            self.EndTimeTextFieldConstraint.constant += self.view.bounds.width
            self.EndTimeDatePickerConstraint.constant += self.view.bounds.width
            self.EventEndTimeLabelConstraint.constant += self.view.bounds.width
 
            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    
    /*OTHER CODE*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //change color of date picker + reset
        jarEndTime.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        
        jarEndTime.datePickerMode = UIDatePickerMode.DateAndTime // 4- use time only
        let currentDate = NSDate()  //5 -  get the current date
        jarEndTime.minimumDate = currentDate  //6- set the current date/time as a minimum
        jarEndTime.date = currentDate.dateByAddingTimeInterval(3600) //7 - defaults to current time but shows how to use it.
        
        jarName.delegate = self
        
        // Do any additional setup after loading the view.
        
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
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    
    @IBAction func createEvent(sender: AnyObject) {
        let time = jarEndTime.date
        let name = jarName.text
        if name == "" {
            displayAlert("Error", displayError: "Please enter a event name!")
        }
        let eventObj = PFObject(className: "events")
        eventObj["eventName"] = name
        eventObj["endTime"] = time
        eventObj["startTime"] = NSDate()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
            
            var currentLocation = locationManager.location
            print(currentLocation)
            var geoPoint = PFGeoPoint(location: currentLocation)
            eventObj["location"] = geoPoint
            
            
        }
        
        eventObj.saveInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            print("Event has been saved.")
            self.eventIDToSubmit = eventObj.objectId! as String
            if(self.fromUsePhoto == true){
                self.submitPhoto()
            }
            else{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }
    @IBAction func cancelPressed(sender: AnyObject) {
        self.delegate?.createEventsViewControllerDidSelect("canceled")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submitPhoto(){
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.labelText = "Saving Picture..."
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            
            let imageData = UIImagePNGRepresentation(self.photoToSubmit)
            let imageFile:PFFile = PFFile(data: imageData!)!
            let cName = "event" + self.eventIDToSubmit
            let imageObj = PFObject(className: cName)
            imageObj["picture"] = imageFile
            imageObj["eventID"] = self.eventIDToSubmit
            imageObj["senderName"] = PFUser.currentUser()?["username"]
            imageObj["score"] = 0
            imageObj["caption"] = self.caption
            do{
                try imageObj.save()
                print("successfully saved the image!")
            }catch {
                print("Unable to save picture")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                progressHUD.hide(true)
                //self.performSegueWithIdentifier("backToFeed", sender: self)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString text: String) -> Bool {
        guard let string = jarName.text else {return true}
        let newLength = string.characters.count + text.characters.count - range.length
        return newLength <= 20
    }
    
    func displayAlert(title: String, displayError: String) {
        let alert = UIAlertController(title: title, message: displayError, preferredStyle: UIAlertControllerStyle.Alert)
        print("diplaying Alert HEYAAAA")
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
