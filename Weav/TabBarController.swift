//
//  TabBarController.swift
//  Weav
//
//  Created by Charles Niu on 4/2/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
import SlidingTabBar

protocol takePictureDelegate {
    func takePicture()
    func storeImage()
}


class TabBarController: UITabBarController, SlidingTabBarDataSource, SlidingTabBarDelegate, UITabBarControllerDelegate, UIGestureRecognizerDelegate, cancelPictureDelegate {
    
    var tabBarView: SlidingTabBar!
    var prevSelectedIndex : Int = 1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let bgImg = UIImage(named: "bgimg")
        self.tabBar.shadowImage = bgImg
        self.tabBar.backgroundImage = bgImg
        self.tabBar.alpha = 0.0

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Right) {
            print("left swipe: " + String(self.selectedIndex))
            if (self.selectedIndex - 1 > -1) {
                tabBarView.barItemSwiped(self.selectedIndex - 1)
            }
        }
        if (sender.direction == .Left) {
            print("right swipe: " + String(self.selectedIndex))
            if (self.selectedIndex + 1 < 3) {
                tabBarView.barItemSwiped(self.selectedIndex + 1)
            }
        }
    }

    
    // MARK: - SlidingTabBarDataSource
    
    func tabBarItemsInSlidingTabBar(tabBarView: SlidingTabBar) -> [UITabBarItem] {
        return tabBar.items!
    }
    
    // MARK: - SlidingTabBarDelegate
    var circleRadius = CGFloat()

    let circleLayer = CAShapeLayer()
    var circlePath = UIBezierPath()
    var circleView = UIView()
    

    
    let circleLayer2 = CAShapeLayer()
    var circlePath2 = UIBezierPath()
    var circleView2 = UIView()
    
    var tPDelegate: takePictureDelegate?
    
    var selectedIndexPrev: Int = 1
    
    // while true,
    var hasTakenPicture : Bool = false
    var isFinishedWithPicture : Bool = false
    
    var checkIcon = UIImageView()
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        print("this is working")
        return true
    }

    func didSelectViewController(tabBarView: SlidingTabBar, atIndex index: Int) {
        prevSelectedIndex = self.selectedIndex
        self.selectedIndex = index
        print(self.selectedIndex)

        if (selectedIndex == 1) {
            let navVC = self.selectedViewController as! UINavigationController
            let camVC = navVC.topViewController as! CameraViewController
            camVC.cancelDelegate = self
            if (!hasTakenPicture) {
                isFinishedWithPicture = false
                tabBarView.slidingTabBarItems[selectedIndex].iconView.alpha = 1
                tabBarView.circleLayer.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor //red
                
                    self.circleView.alpha = 0
                    self.circleView.transform = CGAffineTransformScale(self.circleView.transform, 0.1, 0.1)
                    self.circleView.frame.origin.x = self.view.frame.width/2
                    UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.circleView.alpha = 1
                        self.circleView.transform = CGAffineTransformIdentity
                        self.circleView.frame.origin.x = 0
                        }, completion: nil)
                
                if (selectedIndexPrev == 1) {
                    hasTakenPicture = true
                    
                    tabBarView.slidingTabBarItems[selectedIndex].iconView.alpha = 0
                    
                    //self.circleView2.frame = CGRect(x: 0, y:0, width: tabBarView.frame.width / CGFloat(tabBarItemsInSlidingTabBar(tabBarView).count + 1), height: tabBarView.frame.height)

                    
                    /*let tabBarItemWidth = tabBarView.frame.width / CGFloat(tabBarItemsInSlidingTabBar(tabBarView).count + 1)
                    circleView2 = UIView(frame: CGRect(x: 0, y:0, width: tabBarItemWidth, height: tabBarView.frame.height))
                    circlePath2 = UIBezierPath(arcCenter: CGPoint(x: self.view.frame.width/2, y:2/3 * circleRadius), radius: CGFloat(circleRadius), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)*/
                    
                    self.circleView2.alpha = 1
                    //self.circleView2.frame.origin.x = 0
                    //self.circleView2.transform = CGAffineTransformIdentity
                    
                    
                    self.circleView2.transform = CGAffineTransformScale(self.circleView.transform, 0.1, 0.1)

                    tabBarView.circleLayer.fillColor = UIColor(red: 113/255, green: 245/255, blue: 107/255, alpha: 1).CGColor //green
                    
                    UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.circleView.alpha = 0
                        self.circleView2.alpha = 0
                        self.circleView2.transform = CGAffineTransformScale(self.circleView2.transform, 2.0, 2.0)
                        //self.circleView2.frame.origin.x = -self.view.frame.width/2
                        self.circleView.frame.origin.x = 0

                        self.checkIcon.alpha = 1
                        }, completion: {
                            (value: Bool) in
                            self.circleView.transform = CGAffineTransformIdentity
                            self.circleView.alpha = 1
                    })
                    self.tPDelegate?.takePicture()
                }
            }
            else {
                // hasTakenPicture == true
                if (!isFinishedWithPicture) {
                    self.circleView.alpha = 0
                    self.circleView.transform = CGAffineTransformScale(self.circleView.transform, 0.1, 0.1)
                    self.circleView.frame.origin.x = self.view.frame.width/2
                    UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.checkIcon.alpha = 1
                        tabBarView.circleLayer.fillColor = UIColor(red: 113/255, green: 245/255, blue: 107/255, alpha: 1).CGColor //green
                        self.circleView.alpha = 1
                        self.circleView.transform = CGAffineTransformIdentity
                        self.circleView.frame.origin.x = 0
                        }, completion: nil)
                    
                    if (selectedIndexPrev == 1) {
                        isFinishedWithPicture = true
                        hasTakenPicture = false
                        self.checkIcon.alpha = 0
                        
                        tabBarView.slidingTabBarItems[selectedIndex].iconView.alpha = 1
                        tabBarView.circleLayer.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor //red
                        self.tPDelegate?.storeImage()

                    }
                }
            }
            selectedIndexPrev = 1
        }
        else {

            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.checkIcon.alpha = 0

                self.circleView.alpha = 0
                self.circleView.transform = CGAffineTransformScale(self.circleView.transform, 0.1, 0.1)
                self.circleView.frame.origin.x = self.view.frame.width/2 * 0.9
                }, completion: nil)
            selectedIndexPrev = 0
        }
    }
    
    
    
    
    // MARK: - UITabBarControllerDelegate

    
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // use same duration as for tabBarView.slideAnimationDuration
        return SlidingTabAnimatedTransitioning(transitionDuration: 0.6)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.hidden = true
        self.selectedIndex = 1
        self.delegate = self
        // Do any additional setup after loading the view.
        self.tabBar.translucent = true
        
        
        
        var tabframe = self.tabBar.frame
        let framewidth = self.view.frame.width/5
        tabframe.origin.y = self.view.frame.size.height - framewidth
        self.tabBar.frame = tabframe
        
        //load slidingtabbar cocoapod
        tabBarView = SlidingTabBar(frame: self.tabBar.frame, initialTabBarItemIndex: self.selectedIndex)
        tabBarView.tabBarBackgroundColor = UIColor.blackColor()
        tabBarView.tabBarItemTintColor = UIColor.grayColor()
        tabBarView.selectedTabBarItemTintColor = UIColor.whiteColor()
        tabBarView.selectedTabBarItemColors = [UIColor.clearColor(), UIColor.clearColor(), UIColor.clearColor()]
        tabBarView.slideAnimationDuration = 0.6
        tabBarView.datasource = self
        tabBarView.delegate = self
        tabBarView.setup()
        
        self.view.addSubview(tabBarView)
        
        
        
        //initialize camera circle
        let tabBarItemWidth = tabBarView.frame.width / CGFloat(tabBarItemsInSlidingTabBar(tabBarView).count + 1)
        circleRadius = tabBarItemWidth/2 * 4/5
        circleView = UIView(frame: CGRect(x: 0, y:0, width: tabBarItemWidth, height: tabBarView.frame.height))
        circlePath = UIBezierPath(arcCenter: CGPoint(x: self.view.frame.width/2, y:2/3 * circleRadius), radius: CGFloat(circleRadius), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        circleLayer.path = circlePath.CGPath
        circleLayer.fillColor = UIColor.whiteColor().CGColor
        circleLayer.lineWidth = 0.0
        circleLayer.borderColor = UIColor.whiteColor().CGColor
        circleLayer.borderWidth = 0.5
        circleView.layer.addSublayer(circleLayer)
        circleView.alpha = 1
        //circleLayer.anchorPoint = CGPointMake(tabBarView.frame.width/2, 2/3 * circleRadius)
        tabBarView.addSubview(circleView)
        tabBarView.sendSubviewToBack(circleView)

        
        circleView2 = UIView(frame: CGRect(x: 0, y:0, width: tabBarItemWidth, height: tabBarView.frame.height))
        circlePath2 = UIBezierPath(arcCenter: CGPoint(x: self.view.frame.width/2, y:2/3 * circleRadius), radius: CGFloat(circleRadius), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        circleLayer2.path = circlePath2.CGPath
        circleLayer2.fillColor = UIColor.whiteColor().CGColor
        circleLayer2.lineWidth = 0.0
        circleLayer2.borderColor = UIColor.whiteColor().CGColor
        circleLayer2.borderWidth = 0.5
        circleView2.layer.addSublayer(circleLayer2)
        circleView2.alpha = 0
        tabBarView.addSubview(circleView2)
        tabBarView.sendSubviewToBack(circleView2)
        

        checkIcon = UIImageView(frame: CGRect(x: self.view.frame.width/2, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        checkIcon.frame.origin.x -= 20
        checkIcon.frame.origin.y += 5
        checkIcon.image = UIImage(named: "checkmarkicon")
        checkIcon.image = checkIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        checkIcon.tintColor = UIColor.whiteColor()
        checkIcon.sizeToFit()
        tabBarView.addSubview(checkIcon)
        checkIcon.alpha = 0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pictureCanceled() {
        isFinishedWithPicture = true
        
        hasTakenPicture = false
        self.checkIcon.alpha = 0
        tabBarView.slidingTabBarItems[selectedIndex].iconView.alpha = 1
        tabBarView.circleLayer.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor //red
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
