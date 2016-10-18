//
//  FeedCollectionCell.swift
//  Authtest
//
//  Created by HMCloaner on 8/24/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class FeedCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var normalImage: UIImageView!
    
    @IBOutlet weak var isoPicImage: UIImageView!
    @IBOutlet weak var isoLabel: UILabel!
    @IBOutlet weak var isoPicLabel: UILabel!
    
    var image: UIImageView?
    var label: UILabel?
    
    
    weak var currentItem: Item?
    weak var currentAlbum: Album?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        linkItems()
    }
    
    
    func linkItems() {
        if normalImage != nil {
            image = normalImage
        }
        if isoLabel != nil {
            label = isoLabel
        }
        if isoPicLabel != nil {
            label = isoPicLabel
            image = isoPicImage
        }
    }
    
    
    
    func formatCell(item: Item, album: Album) {
        currentAlbum = album
        currentItem = item
        image?.image = item.picture
        label?.text = currentItem!.itemName + "\n\n" + currentItem!.itemDescription
    }
    
    
}
