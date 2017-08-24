//
//  DiscoverViewController.swift
//  Weav
//
//  Created by SAMEER SURESH on 4/2/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
import Parse

class DiscoverViewController: UIViewController {
    
    
    @IBOutlet weak var segmentCtrl: ADVSegmentedControl!
    
    @IBOutlet var contentView: UIView!
    
    enum TabIndex : Int {
        case FirstChildTab = 0
        case SecondChildTab = 1
    }
    
    var currentViewController: UIViewController?
    var listChildTabVC : UIViewController?
    var mapChildTabVC : UIViewController?


    override func viewDidLoad() {
        super.viewDidLoad()
        //CREATING SEGMENT CONTROL PROPERTIES FOR NAVIGATION BETWEEN LIST AND MAP
        segmentCtrl.items = ["LIST", "MAP"]
        segmentCtrl.font = UIFont(name: "Avenir", size: 12)
        segmentCtrl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentCtrl.selectedIndex = 0
        segmentCtrl.translatesAutoresizingMaskIntoConstraints = true
        segmentCtrl.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        segmentCtrl.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        displayCurrentTab(TabIndex.FirstChildTab.rawValue)
        
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //IBACTION CALLED WHEN SEGMENT CONTROL PRESSED
    @IBAction func switchTabs(sender: AnyObject) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedIndex)
    }
    
    //MOVES SELECTED TAB TO THE FRONT AND ADDS TO THE VIEW
    func displayCurrentTab(tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    //INSTANTIATES LIST OR MAP VIEW CONTROLLER BASED ON WHICH INDEX IS SELECTED
    func viewControllerForSelectedSegmentIndex(index: Int) -> UIViewController? {
        var vc: UIViewController?
        let discoverStoryboard = UIStoryboard(name: "discover", bundle: nil)
        switch index {
        case TabIndex.FirstChildTab.rawValue :
            if listChildTabVC == nil {
                listChildTabVC = discoverStoryboard.instantiateViewControllerWithIdentifier("discoverListVC") as UIViewController!
            }
            vc = listChildTabVC
        case TabIndex.SecondChildTab.rawValue :
            if mapChildTabVC == nil {
                mapChildTabVC = discoverStoryboard.instantiateViewControllerWithIdentifier("discoverMapVC") as UIViewController!
                
            }
            vc = mapChildTabVC
        default:
            return nil
        }
        return vc
    }
    
    //OPTIONS BUTTON, CURRENTLY SUPPORTS LOGOUT ONLY
    @IBAction func OptionButton(sender: AnyObject) {
        let alertController = UIAlertController(title: "Options", message: "", preferredStyle: .ActionSheet)
        let buttonOne = UIAlertAction(title: "Logout", style: .Default, handler: { (action) -> Void in
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            PFUser.logOut()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LandingPage") as! UIViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        })
        let buttonTwo = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in })
        alertController.addAction(buttonOne)
        alertController.addAction(buttonTwo)
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    

}
