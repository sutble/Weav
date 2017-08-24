//
//  FirstPageViewController.swift
//  PicEvent
//
//  Created by Aditya Garg on 1/22/16.
//  Copyright © 2016 Charles Niu. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.view.backgroundColor = UIColor.blackColor()
        let imageName = "WeavLogo.png"
        let image = UIImage(named: imageName)
        let welcomeLabel = UIImageView(image: image!)
        welcomeLabel.frame = CGRectMake(0, 100, 100, 100)
        self.view.addSubview(welcomeLabel)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        let welcomeLabelX = welcomeLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        let welcomeLabelY = welcomeLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
        NSLayoutConstraint.activateConstraints([welcomeLabelX, welcomeLabelY])
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let currentUser = PFUser.currentUser()
        print(currentUser?.username)
        print(currentUser?.password)
        if currentUser != nil {
            self.performSegueWithIdentifier("toMainVC", sender: self)
        }
        else {
            //self.performSegueWithIdentifier("toMainVC", sender: self)
            self.performSegueWithIdentifier("toLogin", sender: self)
        }
        
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
