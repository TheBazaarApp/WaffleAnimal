//
//  FeedCollectionViewCell.swift
//  Authtest
//
//  Created by CSSummer16 on 6/30/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    var currentAlbum : Album?
    var currentImage : UIImage?
    var currentItem : Item?
    var imageIndex = 0
    
    let label = UILabel()
    let textView = UITextView()
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(label)
        self.contentView.addSubview(textView)
        self.contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func setCurrentAlbum(album: Album) {
//        currentAlbum = album
//    }
//    
//    func setCurrentImage(image: UIImage) {
//        currentImage = image
//    }
//    
//    func setCurrentItem(item: Item) {
//        currentItem = item
//    }
    
//    func addConstraints() {
//        self.addConstraintsWithFormat("H:|-4-[v0]|", views: label)
//        self.addConstraintsWithFormat("H:|-4-[v0]|", views: textView)
//        self.addConstraintsWithFormat("H:|[v0]|", views: imageView)
//        self.addConstraintsWithFormat("V:|[v0]-4-[v1]-4-[v2(300)]-4-|", views: label, textView, imageView)
//    }
}
//    extension UIView {
//        
//        func addConstraintsWithFormat(format: String, views: UIView...){
//            var viewsDictionary = [String: UIView]()
//            for (index, view) in views.enumerate() {
//                let key = "v\(index)"
//                viewsDictionary[key] = view
//                view.translatesAutoresizingMaskIntoConstraints = false
//            }
//            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
//            
//        }
//        
//    }

