//
//  RememberViewController.swift
//  Weav
//
//  Created by Jesmin Ngo on 4/2/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
import Parse

class RememberViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
//    @IBOutlet weak var collection: UICollectionView!

    @IBOutlet weak var collectionView: UICollectionView!
    
    static var selectedIndex = 0
    
    var imageArray: [NSURL] = []
    
    var profilepic = UIImageView()
    var id: NSString?
    var name: NSString?
    let defaultpic = UIImage(named: "Default Prof.jpg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.registerClass(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "profileCell")
        self.collectionView.registerClass(SegmentedCollectionViewCell.self, forCellWithReuseIdentifier: "segmentCell")
        self.collectionView.registerClass(RememberCell.self, forCellWithReuseIdentifier: "cell")
        var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView?.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.profilepic = UIImageView(frame: CGRect(x: 0, y: 0, width: 130, height: 130))

        updateArrays()
    }
    
    func updateArrays() {
        print("Update arrays")
        
        imageArray = []
        let query = PFQuery(className:"pictures")
        if FBSDKAccessToken.currentAccessToken() != nil {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name"])
            
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                print("does it go in here?")
                if ((error) != nil)
                {
                    print("printing error!!!!")
                    print(error)
                }
                else
                {
                    if let id: NSString = result.valueForKey("id") as? NSString {
                        print("in here")
                        self.id = id
                        print("name", self.name)
                        query.whereKey("senderName", equalTo: self.id! as! String)
                        query.limit = 500
                        do {
                            let objects = try query.findObjects()
                            for obj in objects{
                                let img = obj["picture"] as! PFFile
                                
                                self.imageArray.append(NSURL(string: img.url!)!)
                            }
                            print(self.imageArray)
                        } catch {
                            print("failed")
                        }
                        print("getting fb id")
                    } else {
                        print("ID is null")
                    }
                }
            })
        } else {
            self.id = PFUser.currentUser()?["username"] as! NSString
            self.name = self.id
            query.whereKey("senderName", equalTo: self.id as! String)
            do {
                let objects = try query.findObjects()
                for obj in objects{
                    let img = obj["picture"] as! PFFile
                    
                    self.imageArray.append(NSURL(string: img.url!)!)
                }
            } catch {
                print("failed")
            }
            print("Not fb")
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
//        if section == 1 {
//            return 1
//        }
        return self.imageArray.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileCell", forIndexPath: indexPath) as! ProfileCollectionViewCell

            cell.bounds = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height / 2)
            cell.backgroundColor = UIColor(red: 242 / 255, green: 195 / 255, blue: 169 / 255, alpha: 1)
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                print("error\(error)")
                if ((error) != nil)
                {
//                    if cell.photoView.image == nil {
                    cell.photoView.image = self.defaultpic
                    cell.name.text = self.name! as String
                }
                else
                {
                    if let id: NSString = result.valueForKey("id") as? NSString {
                        self.id = id as NSString
                        var facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(self.id!)/picture?type=large")
                        cell.photoView.sd_setImageWithURL(facebookProfileUrl)
                    }
                    if let name: NSString = result.valueForKey("name") as? NSString {
                        cell.name.text = name as! String
                    }
                    else {
                        print("name is null")
                    }
                }
            })
            cell.name.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: 30)
            
            cell.photoView.frame.origin.x = cell.frame.width/2 - cell.photoView.frame.width/2
            cell.photoView.frame.origin.y = cell.frame.height/2 - cell.photoView.frame.height/2
            cell.name.textAlignment = NSTextAlignment.Center
            cell.name.frame.origin.y = cell.photoView.frame.origin.y + cell.photoView.frame.height + 20
            cell.photoView.layer.borderWidth = 3
            cell.photoView.layer.masksToBounds = false
            cell.photoView.layer.borderColor = UIColor.whiteColor().CGColor
            cell.photoView.layer.cornerRadius = cell.photoView.frame.height/2
            cell.photoView.clipsToBounds = true
            cell.photoView.contentMode = .ScaleAspectFill
            return cell
//        }
//        if indexPath.section == 1 {
//            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("segmentCell", forIndexPath: indexPath) as! SegmentedCollectionViewCell
//            cell.bounds = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: 40)
////            cell.segmentedControl.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
//            cell.backgroundColor = UIColor.greenColor()
//            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! RememberCell
            cell.image.frame.origin.x = cell.frame.width/2 - cell.image.frame.width/2
            cell.image.frame.origin.y = cell.frame.height/2 - cell.image.frame.height/2
            var imageUrl = self.imageArray[indexPath.item]
            cell.image?.sd_setImageWithURL(imageUrl)
            cell.image?.transform = CGAffineTransformMakeRotation((90 * CGFloat(M_PI)) / 180)
            cell.image?.contentMode = .ScaleAspectFill
            
//            cell.image2?.sd_setImageWithURL(imageUrl)
//            cell.image2?.transform = CGAffineTransformMakeRotation((90 * CGFloat(M_PI)) / 180)
//            cell.image2?.contentMode = .ScaleAspectFill
//            
//            cell.image3?.sd_setImageWithURL(imageUrl)
//            cell.image3?.transform = CGAffineTransformMakeRotation((90 * CGFloat(M_PI)) / 180)
//            cell.image3?.contentMode = .ScaleAspectFill
//            
//            cell.image4?.sd_setImageWithURL(imageUrl)
//            cell.image4?.transform = CGAffineTransformMakeRotation((90 * CGFloat(M_PI)) / 180)
//            cell.image4?.contentMode = .ScaleAspectFill
//            
//            cell.image5?.sd_setImageWithURL(imageUrl)
//            cell.image5?.transform = CGAffineTransformMakeRotation((90 * CGFloat(M_PI)) / 180)
//            cell.image5?.contentMode = .ScaleAspectFill
//            
//            cell.image1?.layer.borderWidth = 1
//            cell.image1?.layer.backgroundColor = UIColor.whiteColor().CGColor
//            cell.image1?.layer.borderColor = UIColor.whiteColor().CGColor
//            cell.image1?.layer.cornerRadius = 6.0
//            
//            cell.image2?.layer.borderWidth = 1
//            cell.image2?.layer.backgroundColor = UIColor.whiteColor().CGColor
//            cell.image2?.layer.borderColor = UIColor.whiteColor().CGColor
//            cell.image2?.layer.cornerRadius = 6.0
//            
//            cell.image3?.layer.borderWidth = 1
//            cell.image3?.layer.backgroundColor = UIColor.whiteColor().CGColor
//            cell.image3?.layer.borderColor = UIColor.whiteColor().CGColor
//            cell.image3?.layer.cornerRadius = 6.0
//            
//            cell.image4?.layer.borderWidth = 1
//            cell.image4?.layer.backgroundColor = UIColor.whiteColor().CGColor
//            cell.image4?.layer.borderColor = UIColor.whiteColor().CGColor
//            cell.image4?.layer.cornerRadius = 6.0
//        
//            cell.image5?.layer.borderWidth = 1
//            cell.image5?.layer.backgroundColor = UIColor.whiteColor().CGColor
//            cell.image5?.layer.borderColor = UIColor.whiteColor().CGColor
//            cell.image5?.layer.cornerRadius = 6.0
            
            cell.image?.viewForLastBaselineLayout.clipsToBounds = true
//            cell.image2?.viewForLastBaselineLayout.clipsToBounds = true
//            cell.image3?.viewForLastBaselineLayout.clipsToBounds = true
//            cell.image4?.viewForLastBaselineLayout.clipsToBounds = true
//            cell.image5?.viewForLastBaselineLayout.clipsToBounds = true
            //cell.backgroundColor = UIColor.yellowColor()
            return cell
        }
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 0.0
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 0.0
//    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (indexPath.section == 1) {
            return CGSizeMake(UIScreen.mainScreen().bounds.width/3, UIScreen.mainScreen().bounds.width/3)
        }
        if (indexPath.section == 0){
            return CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width - 40)
        }
        else {
            return CGSizeMake(UIScreen.mainScreen().bounds.width, 40)
        }
    }
    
    
    
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//        var nib: UINib = UINib(nibName: "ProfileTableViewCell", bundle: nil)
//        self.table.registerNib(nib, forCellReuseIdentifier: "tableCell")
//        let cell = self.table.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileTableViewCell
//        cell.backgroundColor = UIColor.orangeColor()
//        print("WORK")
//        return cell
//    }
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        
//    }
    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        } else {
//            return self.otherMembers.count
//        }
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        if indexPath.section == 0 {
//            let cell = collection.dequeueReusableCellWithReuseIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCollectionViewCell
//            return cell
//        } else {
//            let cell = collection.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! RememberCell
//            cell.image?.image = self.imageArray[indexPath.row]
//            cell.label?.text = self.otherMembers[indexPath.row]
//            return cell
//        }
//    }
//    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int   {
//        return 2
//    }
    
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        var reusableview: UICollectionReusableView? = nil
//        switch kind {
//        //2
//        case UICollectionElementKindSectionHeader:
////            var nib: UINib = UINib(nibName: "RememberHeaderReusableView", bundle: nil)
////            collection.registerNib(nib, forCellWithReuseIdentifier: "HeaderCell")
//            var collectionHeader: UICollectionReusableView = collection.dequeueReusableCellWithReuseIdentifier("HeaderCell", forIndexPath: indexPath)
//            return collectionHeader
//        default:
//            //4
//            assert(false, "Unexpected element kind")
//        }
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSizeMake(0.0, 300.0)
//    }
}