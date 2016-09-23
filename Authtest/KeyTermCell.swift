//
//  KeyTermCell.swift
//  Authtest
//
//  Created by HMCloaner on 9/2/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class KeyTermCell: UITableViewCell {

    
    var icon = UIImageView()
    var keyTermLabel = UILabel()
    var type: KeywordListener.ListenerType!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        keyTermLabel.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        keyTermLabel.numberOfLines = 1
        
        self.contentView.addSubview(icon)
        self.contentView.addSubview(keyTermLabel)
        
        let viewsDict = ["label" : keyTermLabel,
                         "icon" : icon]
        
        //TODO: Fix these
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[icon]-|", options: [], metrics: nil, views: viewsDict))
        let aspectRatioConstraint = NSLayoutConstraint(item: icon, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: icon, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        icon.addConstraint(aspectRatioConstraint)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[icon]-10-[label]|", options: [], metrics: nil, views: viewsDict))
    }
    
    func formatCell(term: String, type: KeywordListener.ListenerType) {
        keyTermLabel.text = term
        self.type = type
        self.icon.image = getIcon()
    }
    
    
    
    func getIcon() -> UIImage {
        switch type! {
        case .Category:
            return UIImage(named: "categories.png")!
        case .Keyword:
            return UIImage(named: "key.png")!
            
        }
    }
    
    
    
    
    
    
    
    
    
}
