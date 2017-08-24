//
//  EnlargePhotoViewController.swift
//  Weav
//
//  Created by SAMEER SURESH on 4/19/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class EnlargePhotoViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var imagevar = NSURL()
    var imageView = UIImageView()
    var nametextvar = String()
    var nameLabel: UILabel!
    var score = Int()
    var scoreLabel: UILabel!
    var captiontextvar = String()
    var capLabel: UILabel!
    var labelBox1: UIImageView!
    var labelBox2: UIImageView!
    let circleLayer = CAShapeLayer()
    var circlePath = UIBezierPath()
    var circleView = UIView()
    var circleRadius = CGFloat()
    var scoreLabel2: UILabel!
    var circleView2 = UIView()
    let circleLayer2 = CAShapeLayer()
    var circleRadius2 = CGFloat()
    var voteLabel: UILabel!
    let dotimg = UIImageView()
    var id = String()
    var reportImage: UIButton!
    var saveImage: UIButton!
    var deleteImage: UIButton!
    var currentUserName = String()
    var backButton: UIButton!
    var yPosArray: [CGFloat] = []
    var indexArray: [NSIndexPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserName = PFUser.currentUser()!["username"] as! String
        setAttributes()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteClicked() {
        let alert = UIAlertController(title: "Delete Picture?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
            let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            progressHUD.labelText = "Deleting Picture..."
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                
                let query = PFQuery(className: "pictures")
                query.whereKey("objectId", equalTo: self.id)
                print(self.id)
                query.findObjectsInBackgroundWithBlock({ (objects : [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        
                        for object in objects! {
                            do {
                                try object.delete()
                            } catch _ {
                                
                            }
                            
                        }
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                dispatch_async(dispatch_get_main_queue()) {
                    progressHUD.hide(true)
                    //self.performSegueWithIdentifier("backToFeed", sender: self)
                }
            }
            
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveClicked() {
        let PortraitImage: UIImage = UIImage(CGImage: imageView.image!.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
        UIImageWriteToSavedPhotosAlbum(PortraitImage, self, nil, nil)
        self.displayAlert("Success", displayError: "Image saved to camera roll.")
        
    }
    
    func reportClicked() {
        var descriptionTF = UITextField()
        let alertController = UIAlertController(title: "Report Image", message: "Please provide a reason for reporting this image.", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Report", style: .Default, handler: { (action) -> Void in
            let reportObj = PFObject(className: "reports")
            reportObj["reporting_user"] = self.currentUserName
            reportObj["submitting_user"] = self.nametextvar
            reportObj["pictureID"] = self.id
            reportObj["report_description"] = descriptionTF.text
            reportObj.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
                self.displayAlert("Reported Image", displayError: "")
            })
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in}
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            descriptionTF = textField
            descriptionTF.placeholder = "Description"
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func backClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>)
    {
        
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        print("tap gesture happening")
        
        if (self.nameLabel.alpha != 1) {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.nameLabel.alpha = 1
                self.scoreLabel.alpha = 1
                self.labelBox1.alpha = 0.5
                self.labelBox2.alpha = 0.5
                self.capLabel.alpha = 1
                
                self.circleView.alpha = 1
                self.circleView.transform = CGAffineTransformIdentity
                
                //self.circleView2.alpha = 1
                //self.circleView2.transform = CGAffineTransformIdentity
                
                self.reportImage.alpha = 1
                self.saveImage.alpha = 1
                self.deleteImage.alpha = 1
                self.backButton.alpha = 1
                
                }, completion: nil)
        }
        else {
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.nameLabel.alpha = 0
                self.scoreLabel.alpha = 0
                self.labelBox1.alpha = 0
                self.labelBox2.alpha = 0
                self.capLabel.alpha = 0
                self.reportImage.alpha = 0
                self.saveImage.alpha = 0
                self.deleteImage.alpha = 0
                self.circleView.alpha = 0
                self.backButton.alpha = 0
                }, completion: {
                    (value: Bool) in
                    self.dotimg.tintColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1)
                    self.circleLayer2.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor
            })
        }
        
        
    }
    
    // for upvote feature
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        let p = gestureRecognizer.locationInView(self.view)
        yPosArray.append(p.y)
        dotimg.image = UIImage(named: "votearrow") as UIImage?
        dotimg.image = dotimg.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.dotimg.tintColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1)
        view.addSubview(dotimg)
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            print("NOW DRAGGING")
            // Set the vote arrow
            let dragVariance = yPosArray[0] - p.y
            var verticalDifference = view.frame.width/5
            // drag up or down
            if dragVariance >= 0 {
                dotimg.transform = CGAffineTransformMakeRotation((0 * CGFloat(M_PI)) / 180)
                verticalDifference *= 1
                if !(dotimg.alpha >= 1) {
                    dotimg.frame = CGRect(x: view.center.x - dotimg.frame.width/2, y: view.center.y - circleView2.frame.height/2 - (dragVariance) - dotimg.frame.height, width: view.frame.width/5 + abs(dragVariance)/10, height: view.frame.width/7 + abs(dragVariance)/10)
                }
                
            } else {
                dotimg.transform = CGAffineTransformMakeRotation((180 * CGFloat(M_PI)) / 180)
                verticalDifference *= -1
                if !(dotimg.alpha >= 1) {
                    dotimg.frame = CGRect(x: view.center.x - dotimg.frame.width/2, y: view.center.y + circleView2.frame.height/2 - (dragVariance), width: view.frame.width/5 + abs(dragVariance)/10, height: view.frame.width/7 + abs(dragVariance)/10)
                }
            }
            dotimg.alpha = abs(dragVariance) * 2/100
            
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                print("BEGAN")
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.nameLabel.alpha = 1
                    self.scoreLabel.alpha = 1
                    self.labelBox1.alpha = 0.5
                    self.labelBox2.alpha = 0.5
                    self.capLabel.alpha = 1
                    
                    self.circleView.alpha = 0
                    self.circleView.transform = CGAffineTransformScale(self.circleView.transform, 0.1, 0.1)
                    
                    self.circleView2.alpha = 1
                    self.circleView2.transform = CGAffineTransformIdentity
                    
                    self.reportImage.alpha = 1
                    self.saveImage.alpha = 1
                    self.backButton.alpha = 1
                    self.deleteImage.alpha = 1
                    
                    }, completion: nil)
            }
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Ended || gestureRecognizer.state == UIGestureRecognizerState.Cancelled {
            print("ENDED")
            if (yPosArray[0] - p.y) >= 0 {
                print("should be working")
                if (dotimg.alpha >= 1) {
                    dotimg.tintColor = UIColor(red: 118/255, green: 205/255, blue: 204/255, alpha: 1)
                    self.circleLayer2.fillColor = UIColor(red: 118/255, green: 205/255, blue: 204/255, alpha: 1).CGColor
                    //self.circleLayer.fillColor = UIColor(red: 118/255, green: 205/255, blue: 204/255, alpha: 1).CGColor
                    
                    self.score += 1
                    print("plus one")
                    updateQuery()
                    scoreLabel.text = String(score)
                    
                    voteLabel.text = "Upvoted!"
                    voteLabel.textColor = UIColor(red: 118/255, green: 205/255, blue: 204/255, alpha: 1)
                    voteLabel.alpha = 1
                }
            }
            else {
                if (dotimg.alpha >= 1) {
                    dotimg.tintColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1)
                    
                    self.circleLayer2.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor
                    //self.circleLayer.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor
                    
                    self.score -= 1
                    print("minus one")
                    updateQuery()
                    scoreLabel.text = String(score)
                    
                    voteLabel.text = "Downvoted!"
                    voteLabel.textColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1)
                    voteLabel.alpha = 1
                }
            }
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.circleView2.alpha = 0
                self.circleView2.transform = CGAffineTransformScale(self.circleView.transform, 0.1, 0.1)
                }, completion: nil)
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.dotimg.alpha = 0.0
                }, completion: {
                    (value: Bool) in
                    UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.voteLabel.alpha = 0
                        }, completion: nil)
            })
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.nameLabel.alpha = 0
                self.scoreLabel.alpha = 0
                self.labelBox1.alpha = 0
                self.labelBox2.alpha = 0
                self.capLabel.alpha = 0
                self.reportImage.alpha = 0
                self.saveImage.alpha = 0
                self.deleteImage.alpha = 0
                self.backButton.alpha = 0
                }, completion: {
                    (value: Bool) in
                    self.dotimg.tintColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1)
                    self.circleLayer2.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor
            })
            
            yPosArray.removeAll()
        }
    }
    
    func updateQuery() {
        let query = PFQuery(className:"pictures")
        query.getObjectInBackgroundWithId(self.id) {
            (obj: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let obj = obj {
                obj["score"] = self.score
                obj.saveInBackground()
            }
        }
        self.scoreLabel.text = String(self.score)
    }
    
    func displayAlert(title: String, displayError: String) {
        let alert = UIAlertController(title: title, message: displayError, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func setAttributes() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        view.viewForLastBaselineLayout.clipsToBounds = true;
        imageView.transform = CGAffineTransformMakeRotation((90 * CGFloat(M_PI)) / 180)
        imageView.alpha = 1
        //imageView.layer.borderWidth = 5
        //imageView.layer.borderColor = UIColor.redColor().CGColor
        imageView.sd_setImageWithURL(imagevar)
        imageView.layer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(imageView)
        imageView.alpha = 1
        
        
        circleRadius = view.frame.width/15
        circleView = UIView(frame: CGRectMake( (circleRadius), (circleRadius * 2), 2*circleRadius, 2*circleRadius))
        
        circlePath = UIBezierPath(arcCenter: CGPoint(x: circleRadius,y: circleRadius), radius: CGFloat(circleRadius), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        circleLayer.path = circlePath.CGPath
        circleLayer.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor
        circleLayer.lineWidth = 0.0
        circleView.layer.addSublayer(circleLayer)
        circleView.alpha = 1
        view.addSubview(circleView)
        
        circleRadius2 = view.frame.width/5
        circleView2 = UIView(frame: CGRectMake( view.frame.width/2 - circleRadius2, view.frame.height/2 - circleRadius2, 2*circleRadius2, 2*circleRadius2))
        let circlePath2 = UIBezierPath(arcCenter: CGPoint(x: circleRadius2,y: circleRadius2), radius: CGFloat(circleRadius2), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        circleLayer2.path = circlePath2.CGPath
        circleLayer2.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor
        circleLayer2.lineWidth = 0.0
        circleView2.layer.addSublayer(circleLayer2)
        circleView2.alpha = 1
        view.addSubview(circleView2)
        
        let labelBoxFrame1 = CGRectMake(0, 0, view.frame.width, circleView.center.y);
        labelBox1 = UIImageView(frame: labelBoxFrame1)
        labelBox1.backgroundColor = UIColor.blackColor()
        labelBox1.alpha = 0.5
        self.view.addSubview(labelBox1)
        view.bringSubviewToFront(labelBox1)
        
        
        let labelBoxFrame2 = CGRectMake(0, view.frame.height - (circleView.center.y * 2/3), view.frame.width, circleView.center.y);
        labelBox2 = UIImageView(frame: labelBoxFrame2)
        labelBox2.backgroundColor = UIColor.blackColor()
        labelBox2.alpha = 0.5
        self.view.addSubview(labelBox2)
        view.bringSubviewToFront(labelBox2)
        
        voteLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        voteLabel.textColor = UIColor.whiteColor()
        voteLabel.translatesAutoresizingMaskIntoConstraints = false
        voteLabel.font = UIFont.systemFontOfSize(12/10 * circleRadius)
        voteLabel.textAlignment = .Center
        view.addSubview(voteLabel)
        
        let voteLabelX =  NSLayoutConstraint(
            item: voteLabel,
            attribute:.CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        let voteLabelY =  NSLayoutConstraint(
            item: voteLabel,
            attribute:.CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)
        NSLayoutConstraint.activateConstraints([voteLabelX, voteLabelY])
        voteLabel.alpha = 0
        view.bringSubviewToFront(voteLabel)
        
        capLabel = UILabel(frame: CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: view.frame.size.height))
        capLabel.textColor = UIColor.whiteColor()
        capLabel.translatesAutoresizingMaskIntoConstraints = false
        capLabel.font = UIFont.systemFontOfSize(8/10 * circleRadius)
        capLabel.textAlignment = .Center
        capLabel.text = captiontextvar
        view.addSubview(capLabel)
        let captionLabelCenter =  NSLayoutConstraint(
            item: capLabel,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        let captionLabelBottom =  NSLayoutConstraint(
            item: capLabel,
            attribute:.Bottom,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: -circleRadius/2)
        NSLayoutConstraint.activateConstraints([captionLabelCenter, captionLabelBottom])
        capLabel.alpha = 1
        view.bringSubviewToFront(capLabel)
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFontOfSize(8/10 * circleRadius)
        nameLabel.textAlignment = .Right
        view.addSubview(nameLabel)
        let nameLabelRight =  NSLayoutConstraint(
            item: nameLabel,
            attribute:.Right,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Right,
            multiplier: 1.0,
            constant: -1*circleRadius)
        let nameLabelTop =  NSLayoutConstraint(
            item: nameLabel,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0,
            constant: circleRadius * 1.5)
        NSLayoutConstraint.activateConstraints([nameLabelRight, nameLabelTop])
        nameLabel.alpha = 1
        nameLabel.text = nametextvar
        view.bringSubviewToFront(nameLabel)
        
        scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: circleView.frame.size.width, height: circleView.frame.size.height))
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.font = UIFont.systemFontOfSize(9/10 * circleRadius)
        scoreLabel.textAlignment = .Center
        scoreLabel.text = String(score)
        circleView.addSubview(scoreLabel)
        scoreLabel.alpha = 1
        view.bringSubviewToFront(circleView)
        
        scoreLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: circleView2.frame.size.width, height: circleView2.frame.size.height))
        scoreLabel2.textColor = UIColor.whiteColor()
        scoreLabel2.font = UIFont.systemFontOfSize(9/10 * circleRadius2)
        scoreLabel2.textAlignment = .Center
        scoreLabel2.text = String(score)
        circleView2.addSubview(scoreLabel2)
        view.addSubview(circleView2)
        circleView2.alpha = 0
        
        backButton = UIButton()
        backButton.frame = CGRectMake((circleRadius * 0.25), view.frame.height - (circleRadius * 1.75), 1.5 * circleRadius, 1.5 * circleRadius)
        backButton.setImage(UIImage(named: "corner triangle"), forState: .Normal)
        backButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(backButton)
        backButton.alpha = 1
        backButton.transform = CGAffineTransformMakeScale(1, -1)
        backButton.addTarget(self, action: "backClicked", forControlEvents: .TouchUpInside)
        
        reportImage = UIButton()
        reportImage.frame = CGRectMake(view.frame.width * 6.5/10 - circleRadius/2, (1.5 * circleRadius), circleRadius, circleRadius)
        reportImage.setImage(UIImage(named: "report2_button"), forState: .Normal)
        reportImage.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(reportImage)
        reportImage.alpha = 1
        view.bringSubviewToFront(reportImage)
        reportImage.addTarget(self, action: "reportClicked", forControlEvents: .TouchUpInside)
        
        saveImage = UIButton()
        saveImage.frame = CGRectMake(view.frame.width/2 - circleRadius/2, 1.5*circleRadius, circleRadius, circleRadius)
        saveImage.setImage(UIImage(named: "save_button"), forState: .Normal)
        saveImage.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(saveImage)
        saveImage.alpha = 1
        view.bringSubviewToFront(saveImage)
        saveImage.addTarget(self, action: "saveClicked", forControlEvents: .TouchUpInside)
        
        if (currentUserName == nametextvar) {
            deleteImage = UIButton()
            deleteImage.frame = CGRectMake(view.frame.width * 3.5/10 - circleRadius/2, (1.5 * circleRadius), circleRadius, circleRadius)
            deleteImage.setImage(UIImage(named: "delete_button"), forState: .Normal)
            deleteImage.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
            view.addSubview(deleteImage)
            deleteImage.alpha = 1
            view.bringSubviewToFront(deleteImage)
            deleteImage.addTarget(self, action: "deleteClicked", forControlEvents: .TouchUpInside)
        }
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.2
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.view.addGestureRecognizer(lpgr)
        let tgr = UITapGestureRecognizer(target:self, action: "handleTap:")
        //tgr.delaysTouchesBegan = true
        tgr.delegate = self
        self.view.addGestureRecognizer(tgr)
        view.setNeedsLayout()
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
