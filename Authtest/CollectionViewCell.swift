//
//  CollectionViewCell.swift
//  buy&sell
//
//  Created by cssummer16 on 6/13/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell, UITextViewDelegate, UITextFieldDelegate {
    
    //This CollectionViewCell is used in the AddNewItem class!
    
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemName: UITextField!
    var item: Item?
    let placeholderText = "description"
    
    
    
    
    //If possible, call initializeListeners() from init.  It crashes when you try - IDK why.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    //**** We need a listener for  item tag too!!!
    
    //Listen for changes in the itemName and itemPrice textFields
    func initializeListeners(){
        itemDescription.delegate = self
        itemPrice.delegate = self
        if itemDescription.text == placeholderText {
            applyTextViewPlaceholder(itemDescription)
        }
        
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
        if let price = Double(textField.text!) {
            item?.price = price
        } else {
            if textField.text! == "" {
                item?.price = -0.1134
            }
        }
    }
    
    
    //Only numbers allowed in price field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet(charactersInString:"0123456789.").invertedSet
        let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
        let numberFiltered = compSepByCharInSet.joinWithSeparator("")
        return string == numberFiltered
        
    }
    
    
    
    
    
    //////////////////////////DEFAULT TEXT FOR DESCRIPTION//////////////////////////////////
    
    func applyTextViewPlaceholder(textView: UITextView) {
        //textView.textColor = UIColor.lightTextColor()
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeholderText
    }
    
    
    
    func getRidOfTextViewPlaceholder(textView: UITextView) {
        textView.textColor = UIColor.darkTextColor()
        textView.alpha = 1.0 //Necessary???
    }
    
    
    
    
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if textView == itemDescription && textView.text == placeholderText {
            moveCursorToStart(textView)
        }
        return true
    }
    
    
    
    
    
    
    
    func moveCursorToStart(textView: UITextView) {
        dispatch_async(dispatch_get_main_queue(), {
            textView.selectedRange = NSMakeRange(0,0)
        })
    }
    
    

    
    
    
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //Number of characters in text view after the user makes their change
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 { //We want the text to be black, etc.
            if textView == itemDescription && textView.text == placeholderText //If the text is placeholder text, get rid of it and change the style
            {
                
                if text.utf16.count == 0 { // they hit the back button
                    return false // ignore it
                }
                getRidOfTextViewPlaceholder(textView)
                textView.text = ""
            }
            return true
        } else { //Empty, so show placeholder text
            applyTextViewPlaceholder(textView)
            moveCursorToStart(textView)
            return false
        }
    }
}
