//
//  CommentTextField.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-15.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class CommentTextField: UITextView {
    
    var tapped : Bool = false
    
    override func awakeFromNib() {
        text = ""
        textColor = UIColor(red: 0, green: 0, blue: 98, alpha: 22)
        layer.cornerRadius = 5.0
        keyboardDismissMode = .Interactive
        font = UIFont.systemFontOfSize(17.0)
        layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        layer.borderWidth = 1.0
        clipsToBounds = true
    }
    
    override func becomeFirstResponder() -> Bool {
        if !tapped {
            textColor = UIColor.blackColor()
           // text = ""
            tapped = true
        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if text == "" {
            tapped = false
            text = ""
            textColor = UIColor(red: 0, green: 0, blue: 98, alpha: 22)
        }
        return super.resignFirstResponder()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
    // Drawing code
    }
    */
}
