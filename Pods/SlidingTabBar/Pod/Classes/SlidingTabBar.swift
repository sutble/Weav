//
//  SlidingTabBar.swift
//  
//
//  Created by Adam Bardon on 29/02/16.
//  Copyright © 2016 Adam Bardon. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php


import UIKit

public protocol SlidingTabBarDataSource {
    func tabBarItemsInSlidingTabBar(tabBarView: SlidingTabBar) -> [UITabBarItem]
}

public protocol SlidingTabBarDelegate {
    func didSelectViewController(tabBarView: SlidingTabBar, atIndex index: Int)
}

public class SlidingTabBar: UIView {
    
    public var datasource: SlidingTabBarDataSource!
    public var delegate: SlidingTabBarDelegate!
    
    public var initialTabBarItemIndex: Int!
    public var slideAnimationDuration: Double!
    
    public var tabBarBackgroundColor: UIColor?
    public var tabBarItemTintColor: UIColor!
    public var selectedTabBarItemTintColor: UIColor?
    public var selectedTabBarItemColors: [UIColor]?
    
    private var tabBarItems: [UITabBarItem]!
    public var slidingTabBarItems: [SlidingTabBarItem]!
    private var tabBarButtons: [UIButton]!
    
    private var slideMaskDelay: Double!
    private var selectedTabBarItemIndex: Int!
    
    private var tabBarItemWidth: CGFloat!
    public var leftMask: UIView!
    private var rightMask: UIView!
    
    
    //charles circle stuff
    public var circleLayer = CAShapeLayer()
    var circlePath = UIBezierPath()
    var circleRadius = CGFloat()
    var leftOverlaySlidingMultiplier = CGFloat()
    
    public init(frame: CGRect, initialTabBarItemIndex: Int = 0) {
        super.init(frame: frame)
        
        self.initialTabBarItemIndex = initialTabBarItemIndex
        selectedTabBarItemIndex = initialTabBarItemIndex
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadTabBarView() {
        self.subviews.forEach { $0.removeFromSuperview() }
        selectedTabBarItemIndex = initialTabBarItemIndex
        setup()
    }
    
    public func setup() {
        tabBarItems = datasource.tabBarItemsInSlidingTabBar(self)
        
        guard let _ = tabBarItems else {
            fatalError("SlidingTabBar: add items in tabBar")
        }
        
        guard let slideAnimationDuration = slideAnimationDuration else {
            fatalError("SlidingTabBar: provide value for slideDuration")
        }
        
        guard let _ = tabBarBackgroundColor else {
            fatalError("SlidingTabBar: provide color for tabBarBackgroundColor")
        }
        
        guard let _ = tabBarItemTintColor else {
            fatalError("SlidingTabBar: provide color for tabBarItemTintColor")
        }
        
        guard let _ = selectedTabBarItemTintColor else {
            fatalError("SlidingTabBar: provide color for selectedTabBarItemTintColor")
        }
        
        guard let selectedTabBarItemColors = selectedTabBarItemColors else {
            fatalError("SlidingTabBar: provide colors for selectedTabBarItemColors")
        }
        
        guard selectedTabBarItemColors.count == tabBarItems.count else {
            fatalError("SlidingTabBar: amount of selectedTabBarItemColors is not equal to amount of tab bar items")
        }
        
        slideMaskDelay = slideAnimationDuration / 2
        
        tabBarButtons = []
        slidingTabBarItems = []
        
        let containers = createTabBarItemContainers()
        
        createTabBarItemSelectionOverlay(containers)
        createTabBarItemSelectionOverlayMask(containers)
        createTabBarItems(containers)
    }
    
    private func createTabBarItemSelectionOverlay(containers: [CGRect]) {
        
        for index in 0..<tabBarItems.count {
            let container = containers[index]
            
            let view = UIView(frame: container)
            
            let selectedItemOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            selectedItemOverlay.backgroundColor = selectedTabBarItemColors![index]
            view.addSubview(selectedItemOverlay)
            
            self.addSubview(view)
        }
    }
    
    private func createTabBarItems(containers: [CGRect]) {
        
        var index = 0
        for item in tabBarItems {
            
            let container = containers[index]
            
            let slidingTabBarItem = SlidingTabBarItem(frame: container, tintColor: tabBarItemTintColor, item: item)
            
            self.addSubview(slidingTabBarItem)
            slidingTabBarItems.append(slidingTabBarItem)
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: container.width, height: container.height))
            button.addTarget(self, action: "barItemTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            
            slidingTabBarItem.addSubview(button)
            tabBarButtons.append(button)
            
            index++
        }
        
        self.slidingTabBarItems[initialTabBarItemIndex].iconView.tintColor = selectedTabBarItemTintColor
    }
    

    
    private func createTabBarItemSelectionOverlayMask(containers: [CGRect]) {
        
        tabBarItemWidth = self.frame.width / CGFloat(tabBarItems.count)
        leftOverlaySlidingMultiplier = CGFloat(initialTabBarItemIndex) * tabBarItemWidth
        let rightOverlaySlidingMultiplier = CGFloat(initialTabBarItemIndex + 1) * tabBarItemWidth
        
        circleRadius = tabBarItemWidth/2 * 4/5
        leftMask = UIView(frame: CGRect(x: tabBarItemWidth, y: -circleRadius/2, width: leftOverlaySlidingMultiplier, height: self.frame.height))

        circlePath = UIBezierPath(arcCenter: CGPoint(x: circleRadius * 5/4,y: circleRadius), radius: CGFloat(circleRadius * 2/3), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        circleLayer.path = circlePath.CGPath
        //circleLayer.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor //orange
        //circleLayer.fillColor = UIColor(red: 118/255, green: 205/255, blue: 204/255, alpha: 1).CGColor //blue
        circleLayer.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor //red

        


        circleLayer.lineWidth = 0.0
        circleLayer.borderColor = UIColor.whiteColor().CGColor
        circleLayer.borderWidth = 0.5
        leftMask.layer.addSublayer(circleLayer)
        leftMask.alpha = 0
        //circleLayer.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor //red

        
        
        //leftMask = UIView(frame: CGRect(x: 0, y: 0, width: leftOverlaySlidingMultiplier, height: self.frame.height))
        //leftMask.backgroundColor = tabBarBackgroundColor
        rightMask = UIView(frame: CGRect(x: rightOverlaySlidingMultiplier, y: 0, width: tabBarItemWidth * CGFloat(tabBarItems.count - 1), height: self.frame.height))
        rightMask.backgroundColor = tabBarBackgroundColor
        rightMask.alpha = 0.0
        
        self.addSubview(leftMask)
        self.addSubview(rightMask)
    }
    
    private func createTabBarItemContainers() -> [CGRect] {
        
        var containerArray = [CGRect]()
        
        for index in 0..<tabBarItems.count {
            let tabBarContainer = createTabBarContainer(index)
            containerArray.append(tabBarContainer)
        }
        
        return containerArray
    }
    
    private func createTabBarContainer(index: Int) -> CGRect {
        
        let tabBarContainerWidth = self.frame.width / CGFloat(tabBarItems.count)
        let tabBarContainerRect = CGRect(x: tabBarContainerWidth * CGFloat(index), y: 0, width: tabBarContainerWidth, height: self.frame.height)
        
        return tabBarContainerRect
    }
    
    private func animateTabBarSelection(from from: Int, to: Int) {
        self.leftMask.alpha = 1

        let overlaySlidingMultiplier = CGFloat(to - from) * tabBarItemWidth
        
        let leftMaskDelay: Double
        let rightMaskDelay: Double
        if overlaySlidingMultiplier > 0 {
            leftMaskDelay = slideMaskDelay
            rightMaskDelay = 0
        }
        else {
            leftMaskDelay = 0
            rightMaskDelay = slideMaskDelay
        }

        UIView.animateWithDuration(slideAnimationDuration - leftMaskDelay/2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.leftMask.frame.origin.x += overlaySlidingMultiplier
            switch to {
            case 0:
                self.circleLayer.fillColor = UIColor(red: 118/255, green: 205/255, blue: 204/255, alpha: 1).CGColor //blue
            case 1:
                self.circleLayer.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor //red
            case 2:
                self.circleLayer.fillColor = UIColor(red: 246/255, green: 144/255, blue: 98/255, alpha: 1).CGColor //orange
            default:
                self.circleLayer.fillColor = UIColor(red: 245/255, green: 107/255, blue: 113/255, alpha: 1).CGColor //red
                break
            }
            
            }, completion: nil)
        
        UIView.animateWithDuration(slideAnimationDuration - rightMaskDelay, delay: rightMaskDelay, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.rightMask.frame.origin.x += overlaySlidingMultiplier
            self.rightMask.frame.size.width += -overlaySlidingMultiplier
            self.slidingTabBarItems[from].iconView.tintColor = self.tabBarItemTintColor
            self.slidingTabBarItems[to].iconView.tintColor = self.selectedTabBarItemTintColor
            
            }, completion: nil)
        
    }
    
    public func barItemTapped(sender : UIButton) {
        let index = tabBarButtons.indexOf(sender)!
        
        animateTabBarSelection(from: selectedTabBarItemIndex, to: index)
        selectedTabBarItemIndex = index
        delegate.didSelectViewController(self, atIndex: index)
    }
    
    public func barItemSwiped(index: Int) {
        
        animateTabBarSelection(from: selectedTabBarItemIndex, to: index)
        selectedTabBarItemIndex = index
        delegate.didSelectViewController(self, atIndex: index)
    }

}
