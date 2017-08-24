//
//  CollectionViewCell.swift
//  PicEvent
//
//  Created by SAMEER SURESH on 11/1/15.
//  Copyright © 2015 Charles Niu. All rights reserved.
//

import UIKit
import Parse

class CollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    var nameLabel: UILabel!
    var scoreLabel: UILabel!
    var captionLabel: UILabel!
    var imageView: UIImageView!
    var labelBox1: UIImageView!
    var labelBox2: UIImageView!
    
    var circlenum: CGFloat = 0.0
    
    var score = Int()
    var id = String()
    var caption = String()
    
    var currentlySelected = false
    
    let circleLayer = CAShapeLayer()
    var circlePath = UIBezierPath()
    var circleView = UIView()
    var circleRadius = CGFloat()
    var scoreLabel2: UILabel!
    var circleView2 = UIView()
    let circleLayer2 = CAShapeLayer()
    var circleRadius2 = CGFloat()
    
    
    let dotimg = UIImageView()
    
    var voteLabel: UILabel!
    var reportImage: UIImageView!
    var enlargeImageButton: UIImageView!
    var enlargeImgButton: UIButton!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // HARD CODE CONSTRAINTS
        contentView.layer.borderWidth = 1
        contentView.layer.backgroundColor = UIColor.whiteColor().CGColor
        contentView.layer.borderColor = UIColor.whiteColor().CGColor
        contentView.layer.cornerRadius = 6.0
        
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        contentView.viewForLastBaselineLayout.clipsToBounds = true;
        contentView.addSubview(imageView)
        
        circleRadius = contentView.frame.width/15
        //circleView = UIView(frame: CGRectMake( contentView.frame.width - (2.5*circleRadius), contentView.frame.height - (2.5*circleRadius), 2*circleRadius, 2*circleRadius))
        circleView = UIView(frame: CGRectMake( (circleRadius), (circleRadius), 2*circleRadius, 2*circleRadius))
        
        circlePath = UIBezierPath(arcCenter: CGPoint(x: circleRadius,y: circleRadius), radius: CGFloat(circleRadius), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        circleLayer.path = circlePath.CGPath
        circleLayer.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor
        circleLayer.lineWidth = 0.0
        circleView.layer.addSublayer(circleLayer)
        circleView.alpha = 0
        
        //let labelBoxFrame1 = CGRectMake(0, circleView.center.y, contentView.frame.width, contentView.frame.height - circleView.center.y);
        let labelBoxFrame1 = CGRectMake(0, 0, contentView.frame.width, circleView.center.y);
        
        labelBox1 = UIImageView(frame: labelBoxFrame1)
        labelBox1.backgroundColor = UIColor.blackColor()
        labelBox1.alpha = 0
        self.contentView.addSubview(labelBox1)
        
        //let labelBoxFrame2 = CGRectMake(0, 0, frame.size.width, 30);
        let labelBoxFrame2 = CGRectMake(0, contentView.frame.height - circleView.center.y, contentView.frame.width, circleView.center.y);
        labelBox2 = UIImageView(frame: labelBoxFrame2)
        labelBox2.backgroundColor = UIColor.blackColor()
        labelBox2.alpha = 0
        self.contentView.addSubview(labelBox2)
        
        //nameLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width, height: frame.size.height))
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFontOfSize(8/10 * circleRadius)
        nameLabel.textAlignment = .Right
        contentView.addSubview(nameLabel)
        let nameLabelRight =  NSLayoutConstraint(
            item: nameLabel,
            attribute:.Right,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Right,
            multiplier: 1.0,
            constant: -1*circleRadius)
        let nameLabelTop =  NSLayoutConstraint(
            item: nameLabel,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Top,
            multiplier: 1.0,
            constant: circleRadius/2)
        NSLayoutConstraint.activateConstraints([nameLabelRight, nameLabelTop])
        nameLabel.alpha = 0
        
        
        scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: circleView.frame.size.width, height: circleView.frame.size.height))
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.font = UIFont.systemFontOfSize(9/10 * circleRadius)
        scoreLabel.textAlignment = .Center
        circleView.addSubview(scoreLabel)
        scoreLabel.alpha = 0
        
        captionLabel = UILabel(frame: CGRect(x: 0, y: frame.size.height, width: frame.size.width, height: frame.size.height))
        captionLabel.textColor = UIColor.whiteColor()
        // captionLabel.backgroundColor = UIColor.redColor()
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.font = UIFont.systemFontOfSize(8/10 * circleRadius)
        captionLabel.textAlignment = .Center
        contentView.addSubview(captionLabel)
        let captionLabelCenter =  NSLayoutConstraint(
            item: captionLabel,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        let captionLabelBottom =  NSLayoutConstraint(
            item: captionLabel,
            attribute:.Bottom,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: -circleRadius/2)
        NSLayoutConstraint.activateConstraints([captionLabelCenter, captionLabelBottom])
        captionLabel.alpha = 1
        
        // Upvote stuff
        // barbaric upvote circle
        circleRadius2 = contentView.frame.width/5
        circleView2 = UIView(frame: CGRectMake( contentView.frame.width/2 - circleRadius2, contentView.frame.height/2 - circleRadius2, 2*circleRadius2, 2*circleRadius2))
        let circlePath2 = UIBezierPath(arcCenter: CGPoint(x: circleRadius2,y: circleRadius2), radius: CGFloat(circleRadius2), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        circleLayer2.path = circlePath2.CGPath
        circleLayer2.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor
        circleLayer2.lineWidth = 0.0
        circleView2.layer.addSublayer(circleLayer2)
        circleView2.alpha = 1
        
        scoreLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: circleView2.frame.size.width, height: circleView2.frame.size.height))
        scoreLabel2.textColor = UIColor.whiteColor()
        scoreLabel2.font = UIFont.systemFontOfSize(9/10 * circleRadius2)
        scoreLabel2.textAlignment = .Center
        circleView2.addSubview(scoreLabel2)
        contentView.addSubview(circleView2)
        circleView2.alpha = 0
        
        contentView.addSubview(circleView)
        contentView.setNeedsLayout()
        
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.3
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.contentView.addGestureRecognizer(lpgr)
        
        
        
        dotimg.image = UIImage(named: "votearrow") as UIImage?
        dotimg.alpha = 0
        dotimg.image = dotimg.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        dotimg.tintColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1)
        contentView.addSubview(dotimg)
        
        voteLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        voteLabel.textColor = UIColor.whiteColor()
        voteLabel.translatesAutoresizingMaskIntoConstraints = false
        voteLabel.font = UIFont.systemFontOfSize(12/10 * circleRadius)
        voteLabel.textAlignment = .Center
        contentView.addSubview(voteLabel)
        let voteLabelX =  NSLayoutConstraint(
            item: voteLabel,
            attribute:.CenterX,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        let voteLabelY =  NSLayoutConstraint(
            item: voteLabel,
            attribute:.CenterY,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)
        NSLayoutConstraint.activateConstraints([voteLabelX, voteLabelY])
        voteLabel.alpha = 0
        
        //REPORT AN IMAGE BUTTON
        reportImage = UIImageView(frame: CGRect(x: circleRadius/2, y: circleRadius/2, width: circleRadius/2, height: circleRadius/2))
        reportImage.image = UIImage(named: "report_button") as UIImage?
        reportImage.image = reportImage.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        reportImage.tintColor = UIColor.whiteColor() //default image color is red
        contentView.addSubview(reportImage)
        reportImage.alpha = 0
        
        
        //ENLARGE AN IMAGE BUTTON
        enlargeImageButton = UIImageView(frame: CGRect(x: contentView.frame.width - (circleRadius * 1.5), y: contentView.frame.height - (circleRadius * 1.5), width: circleRadius, height: circleRadius))
        enlargeImageButton.image = UIImage(named: "corner triangle") as UIImage?
        enlargeImageButton.image = enlargeImageButton.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        enlargeImageButton.tintColor = UIColor.whiteColor()
        contentView.addSubview(enlargeImageButton)
        enlargeImageButton.alpha = 0
        enlargeImageButton.transform = CGAffineTransformMakeScale(-1, -1)
        
        
        
        enlargeImgButton = UIButton()
        enlargeImgButton.frame = CGRectMake(contentView.frame.width - (circleRadius * 1.75), contentView.frame.height - (circleRadius * 1.75), 1.5 * circleRadius, 1.5 * circleRadius)
        enlargeImgButton.setImage(UIImage(named: "corner triangle"), forState: .Normal)
        enlargeImgButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        contentView.addSubview(enlargeImgButton)
        enlargeImgButton.alpha = 0
        enlargeImgButton.transform = CGAffineTransformMakeScale(-1, -1)
    }
    
    
    
    var yPosArray: [CGFloat] = []
    var indexArray: [NSIndexPath] = []
    //var cellArray: [CollectionViewCell] = []
    
    // for upvote feature
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        let p = gestureRecognizer.locationInView(self.contentView)
        yPosArray.append(p.y)
        dotimg.image = UIImage(named: "votearrow") as UIImage?
        dotimg.image = dotimg.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        contentView.addSubview(dotimg)
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            print("NOW DRAGGING")
            // Set the vote arrow
            let dragVariance = yPosArray[0] - p.y
            var verticalDifference = contentView.frame.width/5
            // drag up or down
            if dragVariance >= 0 {
                dotimg.transform = CGAffineTransformMakeRotation((0 * CGFloat(M_PI)) / 180)
                verticalDifference *= 1
            } else {
                dotimg.transform = CGAffineTransformMakeRotation((180 * CGFloat(M_PI)) / 180)
                verticalDifference *= -1
            }
            dotimg.alpha = abs(dragVariance) * 2/100
            // grows in size with drag
            if !(dotimg.alpha >= 1) {
                dotimg.frame = CGRect(x: contentView.center.x - dotimg.frame.width/2, y: contentView.center.y - (dragVariance*contentView.frame.height/150) - dotimg.frame.height/2, width: contentView.frame.width/5 + abs(dragVariance)/10, height: contentView.frame.width/7 + abs(dragVariance)/10)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                print("BEGAN")
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.nameLabel.alpha = 1
                    self.scoreLabel.alpha = 1
                    self.labelBox1.alpha = 0.5
                    self.labelBox2.alpha = 0.5
                    self.captionLabel.alpha = 1
                    
                    self.circleView.alpha = 0
                    self.circleView.transform = CGAffineTransformScale(self.circleView.transform, 0.1, 0.1)
                    
                    
                    self.circleView2.alpha = 1
                    self.circleView2.transform = CGAffineTransformIdentity
                    
                    
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
                    
                    
                    //ExperienceCollectionViewController().collectionView!.reloadData()
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
                    
                    //ExperienceCollectionViewController().voteRequest += 1
                }
            }
            // animate closing
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
                self.captionLabel.alpha = 0
                }, completion: {
                    (value: Bool) in
                    self.dotimg.tintColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1)
                    self.circleLayer2.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor
            })
            
            yPosArray.removeAll()
            //indexArray.removeAll()
            //cellArray.removeAll()
        }
        //}
    }
    
    func updateQuery() {
        
        print("UPDATE QUERY")
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*override func prepareForReuse() {
     super.prepareForReuse()
     print("PREPARE FOR REUSE")
     imageView.image = nil
     nameLabel.text = nil
     scoreLabel.text = nil
     }*/
    
    
}