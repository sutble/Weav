//
//  SlidingTabAnimationController.swift
//
//
//  Created by Adam Bardon on 02/03/16.
//  Copyright © 2016 Adam Bardon. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php

import UIKit

public class SlidingTabAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let transitionDuration: NSTimeInterval

    
    public init(transitionDuration: NSTimeInterval) {
        self.transitionDuration = transitionDuration
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transitionDuration
    }
    
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {

                let fromView = fromVC.view
                let toView = toVC.view
                
                let containerView = transitionContext.containerView()!
                
                containerView.clipsToBounds = false
                containerView.addSubview(toView)
                
                
                var fromViewEndFrame = fromView.frame
                let toViewEndFrame = transitionContext.finalFrameForViewController(toVC)
                var toViewStartFrame = toViewEndFrame
                if (fromVC.tabBarController?.viewControllers?.indexOf(fromVC) < toVC.tabBarController?.viewControllers?.indexOf(toVC)) {
                    fromViewEndFrame.origin.x -= (containerView.frame.width)
                    toViewStartFrame.origin.x += (containerView.frame.width)
                    toView.frame = toViewStartFrame
                }
                else {
                    fromViewEndFrame.origin.x += (containerView.frame.width)
                    toViewStartFrame.origin.x -= (containerView.frame.width)
                    toView.frame = toViewStartFrame
                }
                
                
                /*var fromViewEndFrame = fromView.frame
                fromViewEndFrame.origin.x -= (containerView.frame.width)
                
                let toViewEndFrame = transitionContext.finalFrameForViewController(toVC)
                var toViewStartFrame = toViewEndFrame
                toViewStartFrame.origin.x += (containerView.frame.width)
                toView.frame = toViewStartFrame*/

            
                UIView.animateWithDuration(transitionDuration(transitionContext) * 2/3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    toView.frame = toViewEndFrame
                    fromView.frame = fromViewEndFrame
                    }, completion: { (completed) -> Void in
                        fromView.removeFromSuperview()
                        transitionContext.completeTransition(completed)
                        containerView.clipsToBounds = true
                })                
        }
    }
    
}

