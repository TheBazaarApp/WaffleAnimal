//
//  CollectionViewCell.swift
//  buy&sell
//
//  Created by cssummer16 on 6/13/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //This CollectionViewCell is used in the AddNewItem class!
    
    
    //MARK: OUTLETS AND VARIABLES
    
    @IBOutlet weak var deleteButton: UIImageView!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var itemImage: UIButton!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var tagField: UITextField!
    
    
    
    
    
    
    var addNewItemClass: AddNewItem?
    
    
    
    var item: Item? {
        didSet {
            if item?.itemDescription == placeholderText {
                applyTextViewPlaceholder(itemDescription)
            } else {
                getRidOfTextViewPlaceholder(itemDescription)
            }
        }
    }
    let placeholderText = "Description"
    var categoriesArray = ["None", "Fashion", "Electronics", "Appliances", "Transportation", "Furniture", "School Supplies", "Services", "In Search Of", "Other"]
    var picker = UIPickerView()
    
    
    //MARK: SETUP FUNCTIONS
    
    
    //If possible, call initializeListeners() from init.  It crashes when you try - IDK why.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //**** We need a listener for  item tag too!!!
    
    //Listen for changes in the itemName and itemPrice textFields
    func initializeListeners(){
        itemDescription.delegate = self
        itemName.delegate = self
        itemPrice.delegate = self
        itemPrice.delegate = self
        picker.delegate = self
        picker.dataSource = self
        tagField.inputView = picker
        tagField.delegate = self
        itemName.addTarget(self, action: #selector(itemNameChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        tagField.addTarget(self, action: #selector(itemTagged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        itemPrice.addTarget(self, action: #selector(itemPriceChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    
    
    //MARK: FUNCTIONS FOR TAG FIELD PICKER VIEW
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoriesArray.count
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categoriesArray[row] == "None" {
            tagField.text = ""
        } else {
            tagField.text = categoriesArray[row]
        }
        
        item?.tag = tagField.text!
        if tagField.text! == "In Search Of" {
            if let addClass = addNewItemClass {
                addClass.isoPopup()
            }
        }
        
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoriesArray[row]
    }
    
    
    
    //MARK: LISTENERS FOR TEXT FIELDS
    
    
    
    func textViewDidChange(textView: UITextView) {
        item?.itemDescription = textView.text!
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if textView == itemDescription && textView.text == placeholderText {
            moveCursorToStart(textView)
        }
    }
    
    
    //When the item name is changed, make sure the item's info is updated
    func itemNameChanged(textField: UITextField) {
        item?.itemName = textField.text!
    }
    
    
    func itemTagged(textField: UITextField) {
        item?.tag = textField.text!
    }
    
    
    //When the item price is changed, make sure the item's info is updated
    func itemPriceChanged(textField: UITextField) {
        let trimmedString = String(textField.text!.characters.dropFirst())
        if let price = Double(trimmedString) { //Cut off $, convert to a double //.characters.dropFirst()
            item?.price = price
        } else {
            if textField.text! == "" {
                item?.price = -0.1134
            }
        }
    }
    
    
    //Only numbers allowed in price field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString: String) -> Bool {
        
        if textField == itemPrice {
            let aSet = NSCharacterSet(charactersInString:"0123456789.").invertedSet
            let compSepByCharInSet = replacementString.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            var newString: NSString = NSString(string: itemPrice.text!).stringByReplacingCharactersInRange(range, withString: replacementString)
            //If the field starts out blank, add a $
            if textField.text == "" {
                if replacementString == "$" {
                    return true
                } else {
                    if replacementString == numberFiltered {
                        textField.text = "$"
                        newString = "$" + (newString as String)
                        
                    }
                }
            }
            
            
            //Don't let the user delete the $
            
            if newString == ("$" as NSString) {
                textField.text = ""
            } else {
                if !newString.containsString("$") && newString != ("" as NSString){
                    return false
                }
            }
            
            if textField.text!.containsString(".") {
                if replacementString.containsString(".") { //Return false if the user is trying to type two decimals
                    print("you can't put in 2 decimals")
                    return false
                }
                let newDecimalArray = newString.componentsSeparatedByString(".")
                if newDecimalArray.count == 2 {
                let decimals = newDecimalArray[newDecimalArray.count - 1]
                if decimals.characters.count > 2 { // don't let the user add 3+ decimal places
                    return false
                }
                }
            }
            if textField.text == "$" && newString == "$." { //If the user tries to write $., add in a zero: $0.
                print("got in the right case $.")
                textField.text = "$0"
            }
            
            
            let maxLength = 6
            return replacementString == numberFiltered && newString.length <= maxLength
        }
        if textField == tagField {
            return false
        }
        if textField == itemName {
            let maxLength = 50
            let currentString: NSString = itemName.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: replacementString)
            itemNameChanged(textField)
            return newString.length <= maxLength
        }
        return true
    }
    
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField == itemPrice {
        let trimmedString = String(textField.text!.characters.dropFirst())
        if let price = Double(trimmedString) {
        formatter(String(price))
        }
        }
        return true
    }
    
    
    
    func formatter(price: String) {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let numberFromField = NSString(string: price).doubleValue
        
        itemPrice.text = formatter.stringFromNumber(numberFromField)!.stringByReplacingOccurrencesOfString(",", withString: "")
    }
    
    
    //MARK: DEFAULT TEXT FOR DESCRIPTION BOX
    
    func applyTextViewPlaceholder(textView: UITextView) {
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeholderText
    }
    
    
    
    func getRidOfTextViewPlaceholder(textView: UITextView) {
        textView.textColor = UIColor.darkTextColor()
        textView.alpha = 1.0
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
            let textViewText = textView.text as NSString
            let newText = textViewText.stringByReplacingCharactersInRange(range, withString: text)
            let numberOfChars = newText.characters.count
            return numberOfChars < 400
        } else { //Empty, so show placeholder text
            applyTextViewPlaceholder(textView)
            moveCursorToStart(textView)
            return false
        }
    }
}
