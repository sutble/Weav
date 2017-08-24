//
//  ProfileCollectionViewCell.swift
//  Weav
//
//  Created by Lisa Lee on 4/23/16.
//  Copyright © 2016 Soccerball Squad. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//    }
    var photoView: UIImageView!
    var name: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        photoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 130, height: 130))
        name = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        
        /*var photoView = UIImageView(image: photo)
        photoView.frame = self.frame
        photoView.contentMode = .ScaleAspectFit*/
        contentView.addSubview(photoView)
        contentView.addSubview(name)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }

}
