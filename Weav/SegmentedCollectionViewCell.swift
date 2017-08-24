//
//  SegementedCollectionViewCell.swift
//  Weav
//
//  Created by Lisa Lee on 4/23/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit

class SegmentedCollectionViewCell: UICollectionViewCell {
//    @IBOutlet weak var mainSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var segmentedControl: ADVSegmentedControl!
    
//    @IBAction func selectedSegmentChanged(sender: AnyObject) {
//        RememberViewController.selectedIndex = mainSegmentedControl.selectedSegmentIndex
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        segmentedControl.items = ["My Photos", "My Events", "My Friends"]
//        segmentedControl.font = UIFont(name: "Avenir", size: 12)
//        segmentedControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
//        segmentedControl.selectedIndex = 0
//        segmentedControl.translatesAutoresizingMaskIntoConstraints = true
//        segmentedControl.center = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY)
//        segmentedControl.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
