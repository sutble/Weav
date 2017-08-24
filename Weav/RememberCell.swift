//
//  RememberCell.swift
//  Weav
//
//  Created by Jesmin Ngo on 4/2/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit
class RememberCell: UICollectionViewCell {
    
//    @IBOutlet weak var eventName: UILabel!
//    @IBOutlet weak var image1: UIImageView!
//    @IBOutlet weak var image2: UIImageView!
//    @IBOutlet weak var image3: UIImageView!
//    @IBOutlet weak var image4: UIImageView!
//    @IBOutlet weak var image5: UIImageView!
    var image: UIImageView!
//    var image2: UIImageView!
//    var image3: UIImageView!
//    var image4: UIImageView!
//    var image5: UIImageView!
//    var eventName: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.borderWidth = 1
        contentView.layer.backgroundColor = UIColor.whiteColor().CGColor
        contentView.layer.borderColor = UIColor.whiteColor().CGColor
        contentView.layer.cornerRadius = 6.0
        
        image = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.width))
//        
//        image2 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width/5, height: contentView.frame.width/5))
//        image2.frame.origin.x = contentView.frame.width/5
//        image2.frame.origin.y = 30
//        
//        image3 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width/5, height: contentView.frame.width/5))
//        image3.frame.origin.x = image2.frame.origin.x + contentView.frame.width/5
//        image3.frame.origin.y = 30
//        
//        image4 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width/5, height: contentView.frame.width/5))
//        image4.frame.origin.x = image3.frame.origin.x + contentView.frame.width/5
//        image4.frame.origin.y = 30
//        
//        image5 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width/5, height: contentView.frame.width/5))
//        image5.frame.origin.x = image4.frame.origin.x + contentView.frame.width/5
//        image5.frame.origin.y = 30
//        
//        eventName = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 30))
//        eventName.text = "Event here"
        
        /*var photoView = UIImageView(image: photo)
         photoView.frame = self.frame
         photoView.contentMode = .ScaleAspectFit*/
        contentView.addSubview(image)
//        contentView.addSubview(image2)
//        contentView.addSubview(image3)
//        contentView.addSubview(image4)
//        contentView.addSubview(image5)
//        contentView.addSubview(eventName)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}