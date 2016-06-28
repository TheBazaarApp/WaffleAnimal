//
//  CollectionViewCell.swift
//  buy&sell
//
//  Created by cssummer16 on 6/13/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell, UITextViewDelegate {
    
    //This CollectionViewCell is used in the AddNewItem class!
    
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemName: UITextField!
    var item: Item?
    
    
    
    
    //If possible, call initializeListeners() from init.  It crashes when you try - IDK why.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //**** We need a listener for  item tag too!!!
    
    //Listen for changes in the itemName and itemPrice textFields
    func initializeListeners(){
        itemDescription.delegate = self
        itemName.addTarget(self, action: #selector(itemNameChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        itemPrice.addTarget(self, action: #selector(itemPriceChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    
    
    
    func textViewDidChange(textView: UITextView) {
        item?.itemDescription = textView.text!
    }
    
    
    
    
    //When the item name is changed, make sure the item's info is updated
    func itemNameChanged(textField: UITextField) {
        item?.itemName = textField.text!
    }
    
    
    //When the item price is changed, make sure the item's info is updated
    func itemPriceChanged(textField: UITextField) {
        item?.price = textField.text!
    }
    
    
}
