//
//  CategoryCellWithButton.swift
//  Authtest
//
//  Created by CSSummer16 on 6/20/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class CategoryCellWithButton: UITableViewCell {


    @IBOutlet weak var cellButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

