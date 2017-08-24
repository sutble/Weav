//
// LandingPage.swift
//
//
// Created by Aditya Garg on 12/26/15
//
//
//
//

import UIKit
import AVFoundation
import AVKit
import Parse
import FBSDKLoginKit

class LandingPageViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate, BWWalkthroughViewControllerDelegate {
    
    var state: Int = 1 // 0: forgotPassword, 1: Login, 2: Signup
    var player: AVPlayer?
    var welcomeLabel = UIImageView()
    let username = loginTextField(frame: CGRectMake(10, 10, 10, 10), placeholder: "Username")
    let password = loginTextField(frame: CGRectMake(10, 10, 10, 10), placeholder: "Password")
    let email = loginTextField(frame: CGRectMake(10, 10, 10, 10), placeholder: "Email")
    var loginTop = NSLayoutConstraint()
    var loginTop2 = NSLayoutConstraint() //To switch constraints from bottom of password and email
    var loginTop3 = NSLayoutConstraint()
    var passwordBtnTop = NSLayoutConstraint()
    let loginBtn = UIButton(frame: CGRectMake(40, 360, 240, 40))
    let BottomBtn = UIButton(frame: CGRectMake(40, 420, 240, 40))
    let passwordBtn = UIButton(frame: CGRectMake(40, 420, 240, 40))
    var terms = UITextView()
    //var switcher = 0 //State of the loginBtn
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    var fbUserName : NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            //User is already logged in, do work such as go to next view controller.
            //TEMPORARY FIX UNTIL IMPLEMENT ADDING FB USERS TO PARSE
            print("leaving landing view")
            self.performSegueWithIdentifier("toMainVC", sender: self)
        }
        else
        {
            loginView.center.x = self.view.center.x
            loginView.center.y = self.view.center.y + 198
            
            //change this if we want to ask the user for more permissions later
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
            
        }
        
        let myPlayerView = UIView(frame: self.view.bounds)
        view.addSubview(myPlayerView)
        
        // Load the video from the app bundle.
        let videoURL: NSURL = NSBundle.mainBundle().URLForResource("BackgroundVid", withExtension: "mp4")!
        
        player = AVPlayer(URL: videoURL)
        player?.actionAtItemEnd = .None
        player?.muted = true
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.zPosition = -1
        playerLayer.frame = view.frame
        playerLayer.position = CGPoint.init(x: self.view.center.x, y: self.view.center.y+30)
        view.layer.addSublayer(playerLayer)
        player?.play()
        view.backgroundColor = UIColor.blackColor()
        
        //loop video
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "loopVideo",
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: nil)
        
        var backGroundView = UIView(frame: CGRectMake(0,0, 10, 10))
        let backImageName = "WeavOmbreBackground8.png"
        let backImage = UIImage(named: backImageName)
        //backImage!.height = self.view.bounds.size.height
        //backGroundView.contentMode = .ScaleToFill
        backGroundView = UIImageView(image: backImage!)
        //backGroundView.center.y - 20
        
        //      backGroundView.backgroundColor = UIColor(red: 118/255, green: 205/255, blue: 220/255, alpha: 1)
        backGroundView.alpha = 0.8
        self.view.addSubview(backGroundView)
        
        
        let imageName = "White Weav Logo.png"
        let image = UIImage(named: imageName)
        welcomeLabel = UIImageView(image: image!)
        welcomeLabel.frame = CGRectMake(0, 100, 75, 75)
        
        self.view.addSubview(welcomeLabel)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        let welcomeLabelTop =  NSLayoutConstraint(
            item: welcomeLabel,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0,
            constant: 100)
        let welcomeLabelCenter = welcomeLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        NSLayoutConstraint.activateConstraints([welcomeLabelTop, welcomeLabelCenter])
        
        username.frame = CGRectMake(40, 360, self.view.bounds.size.width, 50)
        createInset(username)
        
        username.addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
        self.view.addSubview(username)
        username.translatesAutoresizingMaskIntoConstraints = false
        let usernameTop =  NSLayoutConstraint(
            item: username,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: welcomeLabel,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 30)
        let usernameCenter = username.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        let usernameHeight = NSLayoutConstraint(item: username, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
                     attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
                     constant: 50)
        let usernameWidth = NSLayoutConstraint(item: username, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
                    constant: self.view.bounds.size.width)
        NSLayoutConstraint.activateConstraints([usernameTop, usernameCenter, usernameHeight, usernameWidth])
        
        password.frame = CGRectMake(40, 360, self.view.bounds.size.width, 50)
        password.secureTextEntry = true
        createInset(password)
        
        password.addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
        self.view.addSubview(password)
        password.translatesAutoresizingMaskIntoConstraints = false
        let passwordTop =  NSLayoutConstraint(
            item: password,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: username,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 1)
        let passwordCenter = password.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        let passwordHeight = NSLayoutConstraint(item: password, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
                     attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
                     constant: 50)
        let passwordWidth = NSLayoutConstraint(item: password, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
                    constant: self.view.bounds.size.width)
        NSLayoutConstraint.activateConstraints([passwordTop, passwordCenter, passwordHeight, passwordWidth])
        
        email.frame = CGRectMake(40, 360, self.view.bounds.size.width, 50)
        email.alpha = 0.0
        createInset(email)
        
        email.addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
        self.view.addSubview(email)
        email.translatesAutoresizingMaskIntoConstraints = false
        let emailTop =  NSLayoutConstraint(
            item: email,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: password,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 1)
        let emailCenter = email.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        let emailHeight = NSLayoutConstraint(item: email, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
                     attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
                     constant: 50)
        let emailWidth = NSLayoutConstraint(item: email, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
                    constant: self.view.bounds.size.width)
        NSLayoutConstraint.activateConstraints([emailTop, emailCenter, emailHeight, emailWidth])
        
        loginBtn.layer.borderColor = UIColor.whiteColor().CGColor
        loginBtn.layer.borderWidth = 2
        loginBtn.titleLabel!.font = UIFont.systemFontOfSize(24)
        loginBtn.tintColor = UIColor.blackColor()
        loginBtn.setTitle("Login", forState: UIControlState.Normal)
        loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //loginBtn.center.x = self.view.center.x
        //loginBtn.center.y = self.view.center.y - 33
        //loginBtn.enabled = false
        self.view.addSubview(loginBtn)
        loginBtn.addTarget(self, action: "Action:", forControlEvents: UIControlEvents.TouchUpInside)
        loginBtn.translatesAutoresizingMaskIntoConstraints = false
        loginTop =  NSLayoutConstraint(
            item: loginBtn,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: password,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 5)
        loginTop2 =  NSLayoutConstraint(
            item: loginBtn,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: email,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 5)
        loginTop3 = NSLayoutConstraint(
            item: loginBtn,
            attribute:.Top,
            relatedBy: .Equal,
            toItem: username,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 5)
        let loginCenter = loginBtn.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        let loginHeight = NSLayoutConstraint(item: loginBtn, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
                     attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
                     constant: 50)
        let loginWidth = NSLayoutConstraint(item: loginBtn, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
                    constant: self.view.bounds.size.width)
        NSLayoutConstraint.activateConstraints([loginTop, loginCenter, loginHeight, loginWidth])
        
        BottomBtn.titleLabel!.font = UIFont.systemFontOfSize(17)
        BottomBtn.tintColor = UIColor.blackColor()
        BottomBtn.setTitle("Or, sign up", forState: UIControlState.Normal)
        BottomBtn.center.x = self.view.center.x
        BottomBtn.center.y = self.view.center.y + 250
        self.view.addSubview(BottomBtn)
        BottomBtn.addTarget(self, action: "bottomBtnAnimation", forControlEvents: UIControlEvents.TouchUpInside)
        //                let switchBottom =  NSLayoutConstraint(
        //                    item: BottomBtn,
        //                    attribute:.Bottom,
        //                    relatedBy: .Equal,
        //                    toItem: view,
        //                    attribute: .Bottom,
        //                    multiplier: 1.0,
        //                    constant: 50)
        //        NSLayoutConstraint.activateConstraints([switchBottom])
        
        passwordBtn.titleLabel!.font = UIFont.systemFontOfSize(17)
        passwordBtn.tintColor = UIColor.blackColor()
        passwordBtn.setTitle("Forgot Password?", forState: UIControlState.Normal)
        passwordBtn.center.x = self.view.center.x
        passwordBtn.center.y = self.view.center.y + 50
        self.view.addSubview(passwordBtn)
        passwordBtn.addTarget(self, action: "forgotPasswordAnimation", forControlEvents: UIControlEvents.TouchUpInside)
        
        //            passwordBtnTop =  NSLayoutConstraint(
        //            item: passwordBtn,
        //            attribute:.Top,
        //            relatedBy: .Equal,
        //            toItem: loginBtn,
        //            attribute: .Bottom,
        //            multiplier: 1.0,
        //            constant: -100)
        let passwordBtnCenter = passwordBtn.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        
        //NSLayoutConstraint.activateConstraints([passwordBtnTop, passwordBtnCenter])
        NSLayoutConstraint.activateConstraints([passwordBtnCenter])
        
        
        
        
        username.delegate = self
        password.delegate = self
        email.delegate = self
        username.autocorrectionType = .No
        password.autocorrectionType = .No
        email.autocorrectionType = .No
        username.autocapitalizationType = .None
        password.autocapitalizationType = .None
        email.autocapitalizationType = .None
        username.clearButtonMode = UITextFieldViewMode.WhileEditing
        password.clearButtonMode = UITextFieldViewMode.WhileEditing
        email.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.view.addSubview(loginView)
        
        
        
    }
    
    //    func showTutorial()
    //    {
    //        let walkthroughVC = self.storyboard?.instantiateViewControllerWithIdentifier("walkthrough") as! BWWalkthroughViewController
    //        let pageOne = self.storyboard?.instantiateViewControllerWithIdentifier("pageOne")
    //        let pageTwo = self.storyboard?.instantiateViewControllerWithIdentifier("pageTwo")
    //        let pageThree = self.storyboard?.instantiateViewControllerWithIdentifier("pageThree")
    //        let pageFour = self.storyboard?.instantiateViewControllerWithIdentifier("pageFour")
    //
    //        walkthroughVC.delegate = self
    //
    //        walkthroughVC.addViewController(pageOne!)
    //        walkthroughVC.addViewController(pageTwo!)
    //        walkthroughVC.addViewController(pageThree!)
    //        walkthroughVC.addViewController(pageFour!)
    //        self.presentViewController(walkthroughVC, animated: true, completion: nil)
    //
    //    }
    func walkthroughCloseButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            //TEMPORARY FIX UNTIL IMPLEMENT ADDING FB USERS TO PARSE
            self.performSegueWithIdentifier("toMainVC", sender: self)
        }
        let currentUser = PFUser.currentUser()
        if (currentUser != nil) {
            self.performSegueWithIdentifier("toMainVC", sender: self)
        }
        
        
        //Tutorial stuff
        //        let userdefaults = NSUserDefaults.standardUserDefaults()
        //        if !userdefaults.boolForKey("hasAlreadyShowedTutorial")
        //        {
        //            showTutorial()
        //
        //            userdefaults.setBool(true, forKey: "hasAlreadyShowedTutorial")
        //            userdefaults.synchronize()
        //        }
        
        
        
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
        
    }
    
    func loopVideo() {
        player?.seekToTime(kCMTimeZero)
        player?.play()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //    // placeholder position
    //    override func textRectForBounds(bounds: CGRect) -> CGRect {
    //        return CGRectInset(bounds, 10, 10)
    //    }
    //    // text position
    //    override func editingRectForBounds(bounds: CGRect) -> CGRect {
    //        return CGRectInset(bounds, 10, 10)
    //    }
    
    func textFieldChanged(textField: UITextField) {
        if(self.state == 1){
            if (!username.text!.isEmpty  && !password.text!.isEmpty){// Text field converted to an Int
                //                print("ayy33")
                //                loginBtn.layer.backgroundColor = UIColor.blackColor().CGColor
                //                loginBtn.titleLabel?.textColor = UIColor.whiteColor()
                //loginBtn.enabled = true
            } else {
                loginBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
                //loginBtn.enabled = false
            }
        }
        else if(self.state == 2){
            if (!username.text!.isEmpty  && !password.text!.isEmpty && !email.text!.isEmpty){
                loginBtn.layer.borderColor = UIColor.blackColor().CGColor
                //loginBtn.enabled = true
            } else {
                loginBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
                //loginBtn.enabled = false
            }
            
        }
    }
    
    
    
    func login() {
        var displayError = ""
        if username.text == "" && password.text == "" {
            displayError = "You must enter a username and password"
        } else if username.text == ""{
            displayError = "You must enter a username"
        } else if password.text == "" {
            displayError = "You must enter a password"
        }
        
        if displayError != "" && self.state == 1 {
            displayAlert("Mistake", displayError: displayError)
        } else{
            PFUser.logInWithUsernameInBackground(self.username.text!, password: self.password.text!){               (success, loginError) in
                if loginError == nil {
                    self.performSegueWithIdentifier("toMainVC", sender: self)
                    
                } else {
                    if let errorString = loginError!.userInfo["error"] as? NSString {
                        displayError = errorString as String
                    } else {
                        displayError = "00ps, something went wrong, please try again later"
                    }
                    
                    self.displayAlert("Could Not Login", displayError: displayError)
                    
                }
            }
        }
    }
    
    func createInset(textField: loginTextField){
        let Inset = UITextView()
        Inset.frame = CGRect(x:10, y:10, width: 10, height: textField.frame.height)
        Inset.backgroundColor = textField.backgroundColor
        textField.leftView = Inset;
        textField.leftViewMode = UITextFieldViewMode.Always
        Inset.userInteractionEnabled = false;
        self.view.addSubview(Inset)
    }
    
    func signUp() {
        
        var displayError = "You forgot to enter a"
        if username.text == "" {
            displayError += " User Name"
        }
        
        if password.text == ""{
            if displayError != "You forgot to enter a" {
                displayError += ", Password"
            } else {
                displayError += " Password"
            }
        }
        
        if email.text == ""{
            if displayError != "You forgot to enter a" {
                displayError += ", and Email Address"
            } else {
                displayError += "n Email Address"
            }
        }
        
        if (displayError != "You forgot to enter a" && self.state == 2) {
            displayAlert("Mistake", displayError: displayError)
        } else{
            
            let user = PFUser()
            user.username = self.username.text!
            user.password = self.password.text!
            user.email = self.email.text!
            
            user.signUpInBackgroundWithBlock { (succeeded, signupError) -> Void in
                if signupError == nil {
                    self.performSegueWithIdentifier("toMainVC", sender: self)
                } else {
                    if let error = signupError!.userInfo["error"] as? NSString{
                        displayError = error as String
                    } else {
                        displayError = "00ps, Please try again later"
                    }
                    self.displayAlert("Mistake", displayError: displayError)
                }
            }
        }
    }
    
    
    func Action(sender:UIButton!)
    {
        if(self.state == 0){
            forgotPassword()
        }
        else if(self.state == 1){
            login()
        }
        else if(self.state == 2){
            signUp()
        }
    }
    
    func forgotPassword(){
        PFUser.requestPasswordResetForEmailInBackground(self.username.text!) { (success, error) -> Void in
            if (error == nil) {
                let success = UIAlertController(title: "Success", message: "Success! Check your email!", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                success.addAction(okButton)
                self.presentViewController(success, animated: false, completion: nil)
                
            }else {
                let errormessage = "error"
                let error = UIAlertController(title: "Cannot complete request", message: errormessage as String, preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                error.addAction(okButton)
                self.presentViewController(error, animated: false, completion: nil)
            }
        }
    }
    
    
    
    func forgotPasswordAnimation(){
        if(self.state == 0){
            print("ayy")
            forgotPasswordToLogin()
        }
        else if(self.state == 1){
            loginToForgotPassword()
        }
    }
    
    func bottomBtnAnimation(){
        if(self.state == 0){ //forgotPassword to Signup
            forgotPasswordToLogin()
        }
        if(self.state == 1){ //LACK OF ELSEIF HERE ALLOWS FOR FORGOT PASSWORD TO JUMP TO SIGNUP HACKY AF
            loginToSignUp()
        }
        else if(self.state == 2){
            signUpToLogin()
        }
        
    }
    
    func loginToSignUp(){
        UIView.animateWithDuration(0.3, animations: {
            NSLayoutConstraint.deactivateConstraints([self.loginTop])
            //NSLayoutConstraint.deactivateConstraints([self.passwordBtnTop])
            self.passwordBtn.alpha = 0
            self.loginBtn.center.y += 50
            NSLayoutConstraint.activateConstraints([self.loginTop2])
        })
        UIView.animateWithDuration(1,
                                   delay: 0,
                                   options: [],
                                   animations:{
                                    self.loginBtn.titleLabel?.alpha = 0
                                    self.loginBtn.setTitle("Sign Up", forState: UIControlState.Normal)
                                    self.BottomBtn.setTitle("Or, login", forState: UIControlState.Normal)
                                    self.loginBtn.titleLabel?.alpha = 1
            },
                                   completion: nil)
        self.email.fadeIn(0.5)
        //        if (!username.text!.isEmpty  && !password.text!.isEmpty && !email.text!.isEmpty){//
        //            print("ayy")
        //            loginBtn.layer.backgroundColor = UIColor.blackColor().CGColor
        //            print("ayy2")
        //            //loginBtn.enabled = false
        //        } else {
        //            loginBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        //            //loginBtn.enabled = true
        //        }
        
        self.state = 2
    }
    func signUpToLogin(){
        UIView.animateWithDuration(0.3, animations: {
            NSLayoutConstraint.deactivateConstraints([self.loginTop2])
            self.loginBtn.center.y -= 50
            NSLayoutConstraint.activateConstraints([self.loginTop])
            self.passwordBtn.alpha = 0.8
            
        })
        
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   options: [],
                                   animations:{
                                    self.loginBtn.titleLabel?.alpha = 0
                                    self.loginBtn.setTitle("Login", forState: UIControlState.Normal)
                                    self.BottomBtn.setTitle("Or, sign up", forState: UIControlState.Normal)
                                    self.loginBtn.titleLabel?.alpha = 1
            },
                                   completion: nil)
        
        self.email.fadeOut(0.1)
        //        if (!username.text!.isEmpty  && !password.text!.isEmpty){
        //            loginBtn.layer.borderColor = UIColor.blackColor().CGColor
        //            //loginBtn.enabled = true
        //        } else {
        //            loginBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        //            //loginBtn.enabled = false
        //        }
        
        self.state = 1
    }
    func forgotPasswordToLogin(){
        
        UIView.animateWithDuration(0.3, animations: {
            NSLayoutConstraint.deactivateConstraints([self.loginTop3])
            //NSLayoutConstraint.deactivateConstraints([self.passwordBtnTop])
            self.passwordBtn.center.y += 50
            self.loginBtn.center.y += 50
            self.passwordBtn.setTitle("forgot password?", forState: UIControlState.Normal)
            NSLayoutConstraint.activateConstraints([self.loginTop])
        })
        UIView.animateWithDuration(1,
                                   delay: 0,
                                   options: [],
                                   animations:{
                                    self.loginBtn.titleLabel?.alpha = 0
                                    self.loginBtn.setTitle("Login", forState: UIControlState.Normal)
                                    self.BottomBtn.setTitle("Or, sign up", forState: UIControlState.Normal)
                                    self.username.attributedPlaceholder = NSAttributedString(string:"Username",
                                        attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
                                    self.username.text = ""
                                    self.loginBtn.titleLabel?.alpha = 1
            },
                                   completion: nil)
        self.password.fadeIn(0.5)
        //        if (!username.text!.isEmpty  && !password.text!.isEmpty){//
        //            loginBtn.layer.borderColor = UIColor.blackColor().CGColor
        //            //loginBtn.enabled = false
        //        } else {
        //            loginBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        //            //loginBtn.enabled = true
        //        }
        
        self.state = 1
        
        
        
    }
    func loginToForgotPassword(){
        UIView.animateWithDuration(0.3, animations: {
            NSLayoutConstraint.deactivateConstraints([self.loginTop])
            self.loginBtn.center.y -= 50
            NSLayoutConstraint.activateConstraints([self.loginTop3])
            self.passwordBtn.center.y -= 50
            self.passwordBtn.setTitle("Nevermind lol", forState: UIControlState.Normal)
            
        })
        
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   options: [],
                                   animations:{
                                    self.loginBtn.titleLabel?.alpha = 0
                                    self.loginBtn.setTitle("Reset my password!", forState: UIControlState.Normal)
                                    self.BottomBtn.setTitle("Or, sign up", forState: UIControlState.Normal)
                                    self.username.attributedPlaceholder = NSAttributedString(string:"Email",
                                        attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
                                    self.loginBtn.titleLabel?.alpha = 1
            },
                                   completion: nil)
        
        self.password.fadeOut(0.1)
        //        if (!username.text!.isEmpty){
        //            loginBtn.layer.borderColor = UIColor.blackColor().CGColor
        //            //loginBtn.enabled = true
        //        } else {
        //            loginBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        //            //loginBtn.enabled = false
        //        }
        
        self.state = 0
        
    }
    
    
    func displayAlert(title: String, displayError: String){
        let alert = UIAlertController(title: title, message: displayError, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
            action in alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        self.performSegueWithIdentifier("toMainVC", sender: self)
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                print("FB Login Button was pressed")
            }
            
            self.returnUserData()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                self.fbUserName = result.valueForKey("name") as! NSString
//                print(result.valueForKey("email") as! NSString)
                let userEmail : NSString = result.valueForKey("email") as! NSString
                let fbId = result.valueForKey("id") as! NSString
                let FBUser = PFUser()
                FBUser.username = fbId as String
                FBUser.email = userEmail as String
                
                if FBUser.isNew
                {
                    print("User signed up through FB")
                } else {
                    print("Returning FB user")
                }
            }
        })
    }
}
