//
//  UIViewExtensions.swift
//
//  Created by Aditya Garg on 1/2/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

class loginTextField: UITextField {
    
    
    required init(coder aDecoder: NSCoder!, placeholder: String) {
        super.init(coder: aDecoder)!
    }
    
    init(frame: CGRect, placeholder: String) {
        super.init(frame: frame)
        //self.layer.cornerRadius = 10.0;
        self.layer.borderColor = UIColor.redColor().CGColor
        self.layer.borderWidth = 1.5
        self.backgroundColor = UIColor.blueColor()
        self.tintColor = UIColor.whiteColor()
        
        self.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                        attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
        self.borderStyle = UITextBorderStyle.Line
        self.textColor = UIColor.blackColor()
        //        self.layer.borderColor = UIColor(red: 118/255, green: 205/255, blue: 204/255, alpha: 1).CGColor
        //        self.backgroundColor = UIColor(red: 118/255, green: 205/255, blue: 204/255, alpha: 1)
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.backgroundColor = UIColor.whiteColor()
        
        self.alpha = 0.8
        self.layer.borderWidth = 1
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.8
            }, completion: completion)}
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
    
    
    
}

//extension UITextField {
//    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
//        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//            self.alpha = 1.0
//            }, completion: completion)  }
//
//    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
//        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//            self.alpha = 0.0
//            }, completion: completion)
//    }
//}

//ICONS
//        let imageView = UIImageView();
//        imageView.frame = CGRect(x:10,y:10,width: username.frame.height, height: 50)
//        let image = UIImage(named: "user.jpeg");
//        imageView.image = image;
//        username.leftView = imageView;
//        username.leftViewMode = UITextFieldViewMode.Always
//        self.view.addSubview(imageView)

extension UIButton {
    
    
    
    func textLogin(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.setTitle("Login", forState: UIControlState.Normal)
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}






