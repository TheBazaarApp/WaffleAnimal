//
//  ViewItemsCell.swift
//  buy&sell
//
//  Created by cssummer16 on 6/20/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase

class ViewItemsCell: UITableViewCell {
    
    //Used by ViewAlbum Class
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumLabel: UILabel!
    
    @IBOutlet weak var viewAlbumsISOLabel: UILabel!
    @IBOutlet weak var viewAlbumsISOBackground: UIView!
    
    @IBOutlet weak var viewAlbumsISOPicImage: UIImageView!
    @IBOutlet weak var viewAlbumsISOPicLabel: UILabel!
    @IBOutlet weak var viewAlbumsISOPicBackground: UIView!
    
    
    
    //Used by ViewItems Class
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    @IBOutlet weak var viewItemsISOLabel: UILabel!
    @IBOutlet weak var viewItemsISOBackground: UIView!
    
    @IBOutlet weak var viewItemsISOPicImage: UIImageView!
    @IBOutlet weak var viewItemsISOPicLabel: UILabel!
    @IBOutlet weak var viewItemsISOPicBackground: UIView!
    
    
    
    
    
    //Used by AlbumImages Class
    @IBOutlet weak var albumItemLabel: UILabel!
    @IBOutlet weak var albumItemImage: UIImageView!
    
    @IBOutlet weak var albumImagesISOLabel: UILabel!
    @IBOutlet weak var albumImagesISOBackground: UIView!
    
    @IBOutlet weak var albumImagesISOPicImage: UIImageView!
    @IBOutlet weak var albumImagesISOPicLabel: UILabel!
    @IBOutlet weak var albumImagesISOPicBackground: UIView!
    
    
    
    
    //Used by the viewSold Class
    @IBOutlet weak var soldImage: UIImageView!
    @IBOutlet weak var soldLabel: UILabel!
    
    @IBOutlet weak var soldItemsISOLabel: UILabel!
    @IBOutlet weak var soldItemsISOBackground: UIView!
    
    @IBOutlet weak var soldItemsISOPicImage: UIImageView!
    @IBOutlet weak var soldItemsISOPicLabel: UILabel!
    @IBOutlet weak var soldItemsISOPicBackground: UIView!
    
    
    
    
    
    //Used by the ViewPurchased Class
    @IBOutlet weak var purchasedImage: UIImageView!
    @IBOutlet weak var purchasedLabel: UILabel!
    
    
    @IBOutlet weak var purchasedItemsISOLabel: UILabel!
    @IBOutlet weak var purchasedItemsISOBackground: UIView!
    
    @IBOutlet weak var purchasedItemsISOPicImage: UIImageView!
    @IBOutlet weak var purchasedItemsISOPicBackground: UIView!
    @IBOutlet weak var purchasedItemsISOPicLabel: UILabel!
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
}
