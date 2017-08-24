//
//  WeavCollectionViewController.swift
//  Weav
//
//  Created by SAMEER SURESH on 4/9/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
import Parse
import DZNEmptyDataSet

private let reuseIdentifier = "Cell"

class WeavCollectionViewController: UICollectionViewController {

    var current_location: CLLocation!
    var eventID: String = ""
    var firstRun: Bool = true
    var notifCreated: Bool = false
    var notifID = [String:UILocalNotification]()
    var didLeaveWithManyPics: Bool = false
    var cell = CollectionViewCell()
    var PHurl = NSURL()
    var PHcaption = String()
    var PHname = String()
    var PHscore = Int()
    var PHid = String()
    
    var noPics = true
    
    var CVcellArray: [CollectionViewCell] = []
    
    class picItemArray  {
        var name = String()
        var score = Int()
        var file = NSURL()
        var id = String()
        var caption = String()
    }
    var picItems : [picItemArray] = []
    
    var largePhotoIndexPath : NSIndexPath? {
        didSet {
            //2
            var indexPaths = [NSIndexPath]()
            if largePhotoIndexPath != nil {
                indexPaths.append(largePhotoIndexPath!)
            }
            if oldValue != nil {
                indexPaths.append(oldValue!)
            }
            //3
            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
                return
            }){
                completed in
                //4
                if self.largePhotoIndexPath != nil {
                    self.collectionView?.scrollToItemAtIndexPath(
                        self.largePhotoIndexPath!,
                        atScrollPosition: .CenteredVertically,
                        animated: true)
                }
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.emptyDataSetSource = self
        self.collectionView!.emptyDataSetDelegate = self
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        self.collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = UIColor(patternImage: UIImage(named: "swirl_pattern")!)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView?.collectionViewLayout = layout
        updateArrays()
        collectionView?.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        largePhotoIndexPath = nil
        if (didLeaveWithManyPics) {
            didLeaveWithManyPics = false
            updateArrays()
            collectionView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateArrays(){
        picItems = []
        if(eventID != ""){
            let queryName = "event" + eventID
            let query = PFQuery(className:queryName)
            do {
                let objects = try query.findObjects()
                for obj in objects{
                    self.noPics = false
                    let img = obj["picture"] as! PFFile
                    let nm = obj["senderName"] as! String
                    let scr = obj["score"] as! Int
                    let oid = obj.objectId! as String
                    let cap = obj["caption"] as! String
                    
                    let pa = picItemArray()
                    pa.name = nm
                    pa.score = scr
                    pa.file = NSURL(string: img.url!)!
                    pa.id = oid
                    pa.caption = cap
                    
                    self.picItems.append(pa)
                }
            } catch {
                NSLog("%@", self.picItems)
            }
            picItems.sortInPlace({ $0.score > $1.score })
            print("finished")
        }
    }



    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if noPics == true{
            return 0
        }
        else{
            return 1
        }
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if noPics == true{
            return 0
        }
        else{
            return self.picItems.count
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        cell.imageView?.image = nil
        // Configure the cell
        CVcellArray.append(cell)
        if noPics == false{
            let url = self.picItems[indexPath.item].file
            cell.imageView?.sd_setImageWithURL(url)
            let placeholder = UIImage(named: "load")
            cell.imageView?.setImageWithURL(url, placeholderImage: placeholder)
            cell.imageView?.transform = CGAffineTransformMakeRotation((90 * CGFloat(M_PI)) / 180)
            cell.imageView.frame.size = cell.frame.size
            //cell.imageView.center = cell.center
            cell.nameLabel?.text = self.picItems[indexPath.item].name
            cell.score = self.picItems[indexPath.item].score
            cell.captionLabel?.text = self.picItems[indexPath.item].caption
            
            cell.id = self.picItems[indexPath.item].id
            cell.scoreLabel.text = String(cell.score)
            cell.scoreLabel2.text = cell.scoreLabel.text
            cell.caption = self.picItems[indexPath.item].caption
            
            
            cell.enlargeImgButton.addTarget(self, action: "enlargeImageSegueAction", forControlEvents: .TouchUpInside)
            
            
            //animate label box
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.cell.nameLabel.alpha = 0
                self.cell.scoreLabel.alpha = 0
                self.cell.labelBox1.alpha = 0
                self.cell.labelBox2.alpha = 0
                self.cell.captionLabel.alpha = 0
                
                self.cell.circleView.alpha = 0
                self.cell.circleView.transform = CGAffineTransformScale(self.cell.circleView.transform, 0.1, 0.1)
                
                self.cell.reportImage.alpha = 0
                self.cell.enlargeImgButton.alpha = 0
                
                }, completion: nil)
            if indexPath == largePhotoIndexPath {
                // EXPERIMENTAL ARENA
                if !cell.currentlySelected {
                    UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.cell.nameLabel.alpha = 1
                        self.cell.scoreLabel.alpha = 1
                        self.cell.labelBox1.alpha = 0.5
                        self.cell.labelBox2.alpha = 0.5
                        self.cell.captionLabel.alpha = 1
                        
                        self.cell.circleView.alpha = 1
                        self.cell.circleView.transform = CGAffineTransformIdentity
                        
                        self.cell.reportImage.alpha = 0
                        self.cell.enlargeImgButton.alpha = 1
                        
                        }, completion: nil)
                    PHurl = url
                    PHcaption = cell.caption
                    PHname = cell.nameLabel.text!
                    PHscore = cell.score
                    PHid = cell.id
                }
                else {
                }
            }
            
            
            cell.layoutIfNeeded()
            cell.alpha = 0
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.cell.alpha = 1.0
                }, completion: nil)
            return cell
        }
        else{
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath == largePhotoIndexPath {
            let size = collectionView.bounds.size
            return CGSizeMake(collectionView.bounds.width, collectionView.bounds.width)
        }
        else {
            return CGSizeMake(UIScreen.mainScreen().bounds.width/3, UIScreen.mainScreen().bounds.width/3)
        }
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if largePhotoIndexPath == indexPath {
            largePhotoIndexPath = nil
        }
        else {
            largePhotoIndexPath = nil
            largePhotoIndexPath = indexPath
        }
        return false
    }

    
    func enlargeImageSegueAction() {
        didLeaveWithManyPics = true
        self.performSegueWithIdentifier("enlargeImage", sender: self)
    }
    
    func displayAlert(title: String, displayError: String) {
        let alert = UIAlertController(title: title, message: displayError, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "enlargeImage" {
            let vc = segue.destinationViewController as! EnlargePhotoViewController
            if (!PHname.isEmpty) {
                vc.imagevar = PHurl
                vc.captiontextvar = PHcaption
                vc.nametextvar = PHname
                vc.score = PHscore
                vc.id = PHid
                
            }
        }
    }
    
    


    deinit {
        self.collectionView!.emptyDataSetSource = nil
        self.collectionView!.emptyDataSetDelegate = nil
    }

}
extension WeavCollectionViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Welcome")
    }
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if(eventID != ""){
            return NSAttributedString(string: "This event has no pictures yet. Be the first to add one!")
        }
        else{
            return NSAttributedString(string: "You have not joined any events yet!")
        }
    }
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo_360")
    }
}

