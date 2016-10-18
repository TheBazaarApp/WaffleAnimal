//
//  FeedTableViewCell.swift
//  Authtest
//
//  Created by HMCloaner on 8/20/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var priceLabelNormal: UILabel!
    @IBOutlet weak var stickerNormal: UIImageView!
    @IBOutlet weak var normalCollectionView: FeedCollectionView!
    
    
    @IBOutlet weak var isoCollectionView: FeedCollectionView!
    @IBOutlet weak var isoSticker: UIImageView!
    @IBOutlet weak var isoPriceLabel: UILabel!
    
    
    var currentAlbum : Album?
    var currentImage : UIImage?
    var currentItem : Item?
    let filledCircle = UIImageView(image: UIImage(named: "ic_lens_18pt")?.imageWithRenderingMode(.AlwaysTemplate))
    var currIndex: Int?
    var shouldSnap = false
    var feedCollectionView: FeedCollectionView!
    var priceLabel: UILabel!
    var sticker: UIImageView!
    
    
    
    
    
    func linkItems() {
        if normalCollectionView != nil {
            feedCollectionView = normalCollectionView!
            priceLabel = priceLabelNormal
            sticker = stickerNormal
        }
        if isoCollectionView != nil {
            feedCollectionView = isoCollectionView!
            priceLabel = isoPriceLabel
            sticker = isoSticker
        }
        
    }
    
    
    
    
    func updateIndex(index: Int) {
        currentAlbum?.imageIndex = index
        currentItem = currentAlbum?.unsoldItems[index]
    }
    
    
    
    func updateCellUI(isAlbumView: Bool) {
        showPrice(currentAlbum!.visibleItemIndex, isAlbumView: isAlbumView)
        setDots(currentAlbum!.visibleItemIndex)
    }
    
    
    
    
    func setDots(index: Int) {
        removeDots()
        let numDots = currentAlbum!.unsoldItems.count
        let selectedIndex = numDots - index - 1
        let height = self.frame.height
        if numDots > 1 {
            var count = numDots - 1
            while count >= 0 {
                
                var newCircle: UIImageView!
                
                if count == selectedIndex {
                    newCircle = filledCircle
                }
                else {
                    newCircle = UIImageView(image: UIImage(named: "ic_panorama_fish_eye_18pt")?.imageWithRenderingMode(.AlwaysTemplate))
                }
                
                let imageWidth = Int(frame.width)
                let width = imageWidth - (15 * (count+1))
                let metrics = ["imageWidth": imageWidth,
                               "width": width,
                               "height": height - 55] as [String: AnyObject]
                newCircle.tintColor = mainClass.ourBlue
                self.contentView.addSubview(newCircle)
                let viewsDict = ["dots": newCircle]
                newCircle.translatesAutoresizingMaskIntoConstraints = false
                contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-height-[dots(10)]", options: [], metrics: metrics, views: viewsDict))
                contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-width-[dots(10)]", options: [], metrics: metrics, views: viewsDict))
                count-=1
            }
        } else {
            filledCircle.removeFromSuperview()
            var loopcount = 0
            for subview in self.contentView.subviews {
                loopcount+=1
                if subview.frame.height == 18.0 {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    func removeDots() {
        filledCircle.removeFromSuperview()
        var loopcount = 0
        for subview in self.contentView.subviews {
            loopcount+=1
            if subview.frame.size.width == 10.0 {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    
    
    func showPrice(index: Int, isAlbumView: Bool) {
        print("showPrice called")
        var item: Item!
        if isAlbumView {
            item = currentAlbum!.unsoldItems[index]
        } else {
            item = currentItem
        }
        let price = item.price
        var priceString = "$"
        let isInteger = floor(price) == price
        if isInteger {
            priceString += String(Int(price))
        }
        else {
            priceString += String(price)
        }
        if price == 0 || price == -0.1134 {
            if item.tag == "In Search Of" {
                priceString = "No Price"
            } else {
                priceString = "Free"
            }
        }
        
        priceLabel.text = priceString
    }
    
    
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>> //TODO: Learn what this is actually doing
        (dataSourceDelegate: D, row: Int, tvc: FeedTableViewCell) {
        
        feedCollectionView.delegate = dataSourceDelegate
        feedCollectionView.dataSource = dataSourceDelegate
        feedCollectionView.tag = row
        print("making sure stuff exists")
        print("-- self--")
        print(self)
        print("---feedcollectionview---")
        print(feedCollectionView)
        print("-- type--")
        // print(feedCollectionView.dynamicType)
        feedCollectionView.ftvc = tvc
        feedCollectionView.reloadData()
    }
    
    
    
    
    
}
