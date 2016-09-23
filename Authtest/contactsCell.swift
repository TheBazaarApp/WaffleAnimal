//
//  contactsCell.swift
//  Authtest
//
//  Created by cssummer16 on 7/7/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class contactsCell: UITableViewCell {
    
    
    
    var receiveruid: String = ""
    let nameLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor.blueColor()
        contentView.addSubview(nameLabel)
        
        let viewsDict = ["label" : nameLabel]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: [], metrics: nil, views: viewsDict))
    }
    

    
    
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
