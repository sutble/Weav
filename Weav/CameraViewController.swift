//
//  CameraViewController.swift
//  Weav
//
//  Created by Lisa Lee on 3/19/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
import CameraEngine
import IGLDropDownMenu
import Parse
import MBProgressHUD
import FBSDKLoginKit

protocol cancelPictureDelegate {
    func pictureCanceled()
}

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, takePictureDelegate, IGLDropDownMenuDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, CreateEventsViewControllerDelegate{
    
    var cameraEngine = CameraEngine()
    
    var locationManager:CLLocationManager!
    var current_location: CLLocation!
    var all_events = [String:String]()
    
    var toSubmit = false
    
    var eventList:NSArray = ["Birthday Party", "Waaergo", "aergijeagr", "oeaurihg"]
    var dropDownMenu = IGLDropDownMenu()
    var selectedItem = IGLDropDownItem()
    var cancelButton = UIButton()
    var created_event:Bool = false
    var create_canceled:Bool = false
    
    var cancelImage = UIImageView()
    var cancelDelegate: cancelPictureDelegate?
    
    var eventID : String = ""
    var senderName: String = ""
    
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraEngine.startSession()
        self.pictureView.hidden = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        cancelImage = UIImageView(frame: CGRectMake(15, 45, 30, 30))
        cancelImage.image = UIImage(named: "cancelImage")
        cancelImage.alpha = 0
        cancelImage.image = cancelImage.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cancelImage.tintColor = UIColor.whiteColor()
        cancelImage.userInteractionEnabled = true
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tgr.delegate = self
        cancelImage.addGestureRecognizer(tgr)
        
        self.view.addSubview(cancelImage)
        
        let tbVC = self.tabBarController as! TabBarController
        tbVC.tPDelegate = self
        
        pictureView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        imageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.view.bringSubviewToFront(cancelButton)

    }
    
    override func viewDidAppear(animated: Bool) {
        if (create_canceled == false) {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.all_events = [:]
        current_location = locations.last
        manager.stopUpdatingLocation()
        let query = PFQuery(className:"events")
        do {
            let objects = try query.findObjects()
            for obj in objects{
                let loc = obj["location"] as! PFGeoPoint
                let latitude: CLLocationDegrees = loc.latitude
                let longtitude: CLLocationDegrees = loc.longitude
                let location: CLLocation = CLLocation(latitude: latitude, longitude: longtitude)
                let dist = (current_location.distanceFromLocation(location)/1000)/1.60934
                if(dist < 0.125){
                    let endTime = obj["endTime"] as! NSDate
                    let currentDate = NSDate()
                    if (endTime.isGreaterThanDate(currentDate)) {
                        if(!self.all_events.keys.contains(obj.objectId! as String)){
                            self.all_events[obj.objectId! as String] = obj["eventName"] as! String
                        }
                    }
                }
            }
            setDropDownProperties()
            getSenderName()
        } catch {
            print("error!")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if(self.created_event == true && self.create_canceled == false){
            resetCamera()
        }
        self.create_canceled = false
        self.created_event = false
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        cancelDelegate?.pictureCanceled()
        resetCamera()
    }
    
    func resetCamera() {
        self.imageView.hidden = true
        self.pictureView.hidden = true
        self.cancelDelegate?.pictureCanceled()
        UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.dropDownMenu.frame = CGRectMake(37.5, 40, self.dropDownMenu.frame.width, self.dropDownMenu.frame.height)
            self.cancelImage.alpha = 0
            }, completion: nil)
    }
    
    @IBAction func switchCamera(sender: AnyObject) {
        self.cameraEngine.switchCurrentDevice()
    }
    
    func setDropDownProperties() {
        var dropdownItems:NSMutableArray = NSMutableArray()
        for id in self.all_events.keys {
            var item = IGLDropDownItem()
            item.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
            item.text = self.all_events[id]
            dropdownItems.addObject(item)
        }
        var createEventItem = IGLDropDownItem()
        createEventItem.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        createEventItem.text = "Create New Event"
        dropdownItems.addObject(createEventItem)
        dropDownMenu.menuText = "Choose Event"
        dropDownMenu.menuButton.backgroundColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1)
        dropDownMenu.menuButton.textLabel.textColor = UIColor.whiteColor()
        dropDownMenu.dropDownItems = dropdownItems as [AnyObject]
        dropDownMenu.paddingLeft = 15
        dropDownMenu.frame = CGRectMake(37.5, 40, self.view.frame.width - 75, 40)
        dropDownMenu.delegate = self
        dropDownMenu.type = IGLDropDownMenuType.SlidingInBoth
        dropDownMenu.gutterY = 5
        dropDownMenu.itemAnimationDelay = 0.1
        //dropDownMenu.rotate = IGLDropDownMenuRotate.Random //add rotate value for tilting the
        dropDownMenu.reloadView()
        self.view.addSubview(dropDownMenu)
    }
    
    func dropDownMenu(dropDownMenu: IGLDropDownMenu!, selectedItemAtIndex index: Int) {
        self.selectedItem = dropDownMenu.dropDownItems[index] as! IGLDropDownItem
        for id in self.all_events.keys {
            if (selectedItem.text == self.all_events[id]) {
                self.eventID = id
            }
        }
    }
    
    func getSenderName() {
        if (PFUser.currentUser()?["username"] != nil) {
            self.senderName = (PFUser.currentUser()?["username"])! as! String
        }
        else {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    print(error)
                }
                else
                {
                    if let name: NSString = result.valueForKey("name") as? NSString {
                        self.senderName = name as String
                    } else {
                        print("ID is null")
                    }
                }
            })
        }
    }
    
    func takePicture() {
        print("camera button tap")
        self.cameraEngine.capturePhoto { (image: UIImage?, error: NSError?) -> (Void) in
            self.imageView.image = image
            print("here")
            self.imageView.hidden = false
            self.pictureView.hidden = false
            self.cancelImage.frame.origin.y += 10
            UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.dropDownMenu.frame = CGRectMake(60, 40, self.dropDownMenu.frame.width, self.dropDownMenu.frame.height)
                self.cancelImage.alpha = 1
                self.cancelImage.frame.origin.y -= 10
                
                }, completion: nil)
            self.view.bringSubviewToFront(self.cancelImage)
            //self.storeImage()
        }
    }
    
    func storeImage() {
        if (selectedItem.text == nil) {
            let alertController = UIAlertController(title: "Please Choose an Event!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else if (selectedItem.index != dropDownMenu.dropDownItems.count - 1) {
            
            let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            progressHUD.labelText = "Saving Picture..."
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                
                print("also here")
                let imageData = UIImagePNGRepresentation((self.imageView.image)!)
                let imageFile:PFFile = PFFile(data: imageData!)!
                let className = "event" + self.eventID
                let imageObj = PFObject(className: className)
                imageObj["picture"] = imageFile
                imageObj["eventID"] = self.eventID
                imageObj["senderName"] = self.senderName
                imageObj["score"] = 0
//                if (self.captionBox.text! != "") {
//                    imageObj["caption"] = self.captionBox.text!
//                } else {
//                    imageObj["caption"] = ""
//                }
                imageObj["caption"] = ""
                do{
                    try imageObj.save()
                    print("successfully saved the image!")
                }catch {
                    print("Unable to save picture")
                }
                
                
                let imageObj2 = PFObject(className: "pictures")
                imageObj2["picture"] = imageFile
                imageObj2["eventID"] = self.eventID
                imageObj2["senderName"] = self.senderName
                imageObj2["score"] = 0
                imageObj2["caption"] = ""
                do{
                    try imageObj2.save()
                    print("successfully saved the image!")
                }catch {
                    print("Unable to save picture")
                }
//                let user = PFUser.currentUser()
//                var userEvents = user?["joinedEvents"] as? [String]
//                if (userEvents != nil) {
//                    if (!userEvents!.contains(self.eventID)) {
//                        userEvents!.append(self.eventID)
//                        user?.setObject(userEvents!, forKey: "joinedEvents")
//                        user?.saveInBackground()
//                    }
//                }
                
                
                dispatch_async(dispatch_get_main_queue()) {
                    progressHUD.hide(true)
                }
            }
            resetCamera()
        } else {
            self.created_event = true
            
            self.performSegueWithIdentifier("photoToCreate", sender: self)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "photoToCreate" {
            let nav = segue.destinationViewController as! UINavigationController
            let dvc2 = nav.topViewController as! CreateEventsViewController
            dvc2.fromUsePhoto = true
            dvc2.photoToSubmit = self.imageView!.image
//            if(self.captionBox.text! != ""){
//                dvc2.caption = self.captionBox.text!
//            }
            dvc2.delegate = self
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        let layer = self.cameraEngine.previewLayer
        
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, atIndex: 0)
        self.view.layer.masksToBounds = true
    }
    
    func createEventsViewControllerDidSelect(value: String){
        self.create_canceled = true
    }

    
}
