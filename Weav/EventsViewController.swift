//
//  EventsViewController.swift
//  Weav
//
//  Created by SAMEER SURESH on 4/2/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import DZNEmptyDataSet

class CustomEventViewCell : UITableViewCell {
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func loadItem(title: String, image: String) {
        backgroundImage.image = UIImage(named: image)
        titleLabel.text = title
    }
}

class EventsViewController: UIViewController {
    
    class eventArray  {
        var eventName = String()
        var eventID = String()
        var endTime = NSDate()
        var eventLocation = Double()
    }
    var eventItems : [eventArray] = []
    var eventTimesCountdown: [NSDate] = []
    
    var notifDict = [NSDate : String]()
    var locationManager: CLLocationManager!
    var refresher: UIRefreshControl!
    var current_location: CLLocation!
    
    var justViewDidLoaded: Bool = false
    var no_events: Bool = false
    var didFindLoc: Bool = false
    
    let cellSpacingHeight: CGFloat = 10

    @IBOutlet weak var eventTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        justViewDidLoaded = true
        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let nib = UINib(nibName: "CustomEventViewCell", bundle: nil)
        eventTableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action:"refresh", forControlEvents:UIControlEvents.ValueChanged)
        eventTableView.addSubview(refresher)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        performQuery()
        
        eventTableView.emptyDataSetDelegate = self
        eventTableView.emptyDataSetSource = self
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (!justViewDidLoaded) {
            locationManager.startUpdatingLocation()
            performQuery()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refresh() {
        self.performQuery()
        eventTableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    func performQuery() {
        eventItems = []
        eventTimesCountdown = []
        let query = PFQuery(className:"events")
        let objects = query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            self.no_events = true
            for obj in objects! {
                let loc = obj["location"] as! PFGeoPoint
                let latitude: CLLocationDegrees = loc.latitude
                let longtitude: CLLocationDegrees = loc.longitude
                let location: CLLocation = CLLocation(latitude: latitude, longitude: longtitude)
                if(self.didFindLoc == true){
                    let dist = (self.current_location.distanceFromLocation(location)/1000)/1.60934

                    let filteredEndTime = (obj["endTime"] as! NSDate).dateByAddingTimeInterval(3600 * 24 * 10)
                    let currentDate = NSDate()
                    
                    if(dist < 15 && filteredEndTime.isGreaterThanDate(currentDate)){
                        self.no_events = false
                        let eventName = obj["eventName"] as! String
                        let endTime = obj["endTime"] as! NSDate
                        let distRounded = Double(round(100*dist)/100)
                        
                        let eventDate = eventArray()
                        eventDate.eventName = eventName
                        eventDate.eventID = obj.objectId!
                        eventDate.endTime = endTime
                        eventDate.eventLocation = distRounded
                        self.eventItems.append(eventDate)
                    }
                }
            }
            self.eventTableView.reloadData()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "eventsToCollection"){
            let vc = segue.destinationViewController as! WeavCollectionViewController
            let row = (sender as! NSIndexPath).section;
            let id = eventItems[row].eventID
            let name = eventItems[row].eventName
            let time = eventItems[row].endTime
            vc.eventID = id
            vc.current_location = self.current_location
        }
    }
    
    deinit{
        self.eventTableView!.emptyDataSetSource = nil
        self.eventTableView!.emptyDataSetDelegate = nil
    }

}

extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
}

extension EventsViewController: CLLocationManagerDelegate
{
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        current_location = locations.last
        self.didFindLoc = true
        manager.stopUpdatingLocation()
    }
}

extension EventsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if (self.no_events == true) {
            return NSAttributedString(string: "Yikes!")

        }
        return NSAttributedString(string: "Loading...")
    }
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if (self.no_events == true) {
            return NSAttributedString(string: "There are no events in your area. Try creating one!")
        }
        return NSAttributedString(string: "")
        
    }
//    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "logo_360")
//    }
}

extension EventsViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.eventItems.count
    }
    
    // There is just one row in every section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func getTimeText(eventTime: NSDate, currentTime: NSDate) -> String {
        if (eventTime.isLessThanDate(currentTime)) {
            return "Event is over"
        }
        else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm" //"yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            return "Ends at " + dateFormatter.stringFromDate(eventTime)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:CustomEventViewCell = eventTableView.dequeueReusableCellWithIdentifier("customCell") as! CustomEventViewCell
        
        cell.titleLabel?.text = self.eventItems[indexPath.section].eventName
        
        let eventTime = eventItems[indexPath.section].endTime
        let currentTime = NSDate()
        cell.timeLabel?.text = getTimeText(eventTime, currentTime: currentTime)
        cell.distanceLabel?.text = String(self.eventItems[indexPath.section].eventLocation) + " miles away"
        
        let tealImage : UIImage = UIImage(named: "tealBackground.png")!
        let redImage : UIImage = UIImage(named: "redBackground.png")!
        let orangeImage : UIImage = UIImage(named: "orangeBackground.png")!
        
        if indexPath.section%3 == 1 {
            cell.backgroundImage?.image = tealImage
        } else if indexPath.section%3 == 2 {
            cell.backgroundImage?.image = redImage
        } else if indexPath.section%3 == 0 {
            cell.backgroundImage?.image = orangeImage
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("eventsToCollection", sender: indexPath)
    }

}
