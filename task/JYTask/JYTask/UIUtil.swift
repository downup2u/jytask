//
//  UIUtil.swift
//  JYTask
//
//  Created by wxqdev on 14-10-27.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation
import UIKit

func addPaddedLeftView(textField: UITextField, image: UIImage) {
    let imageView = UIImageView(image: image)
    // TODO: We should resize the raw image instead of programmatically scaling it.
    let scale: CGFloat = 1.0
    imageView.frame = CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)
    let padding: CGFloat = 10
    let paddingView = UIView(frame: CGRectMake(0, 0, imageView.bounds.width + padding, imageView.bounds.height - 1))
    imageView.center = paddingView.center
    paddingView.addSubview(imageView)
    textField.leftView = paddingView
    textField.leftViewMode = UITextFieldViewMode.Always
}


func addSecureTextSwitcher(textField: UITextField, image: UIImage) -> UIButton {
    
    // TODO: We should resize the raw image instead of programmatically scaling it.
    let scale: CGFloat = 1.0
    let button = UIButton(frame: CGRectMake(0, 0, 40, 40))
    button.setImage(image, forState: UIControlState.Normal)
    let padding: CGFloat = 10
    let paddingView = UIView(frame: CGRectMake(0, 0, button.bounds.width + padding, button.bounds.height))
    button.center = paddingView.center
    paddingView.addSubview(button)
    textField.rightView = paddingView
    textField.rightViewMode = UITextFieldViewMode.Always
    return button
}

func addTextFieldButton(textField: UITextField, btnText:String)-> UIButton{
    let button = UIButton(frame: CGRectMake(0, 0, 100, 40))
    button.setTitle(btnText, forState: UIControlState.Normal)
    let padding: CGFloat = 10
    let paddingView = UIView(frame: CGRectMake(0, 0, button.bounds.width + padding, button.bounds.height))
    button.center = paddingView.center
    paddingView.addSubview(button)
    textField.rightView = paddingView
    textField.rightViewMode = UITextFieldViewMode.Always
    return button

}

func addButtonCorner(btn:UIButton){

  //  btn.setBackgroundImage(UIImage.imageWithColor(UIColor.grayColor()), forState: UIControlState.Disabled)
  //  btn.setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHex("#1E90FF")), forState: UIControlState.Normal)
//    btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
//    btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    
    btn.layer.borderColor = UIColor.clearColor().CGColor
    btn.layer.borderWidth = 1
    btn.layer.cornerRadius = 6
    btn.layer.masksToBounds = true

}

func addButtonCorner_Red(btn:UIButton){
    
    btn.setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHex("#FF0000")), forState: UIControlState.Normal)
    btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    
    btn.layer.borderColor = UIColor.clearColor().CGColor
    btn.layer.borderWidth = 1
    btn.layer.cornerRadius = 6
    btn.layer.masksToBounds = true
    
}
func addButtonCorner_OK(btn:UIButton){
    
    btn.setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHex("#0066FF")), forState: UIControlState.Normal)
    btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    
    btn.layer.borderColor = UIColor.clearColor().CGColor
    btn.layer.borderWidth = 1
    btn.layer.cornerRadius = 6
    btn.layer.masksToBounds = true
    
}
func addButtonCorner_Normal(btn:UIButton){
    
    btn.setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
    btn.setTitleColor(UIColor.colorWithHex("#0066FF"), forState: UIControlState.Normal)
    
    btn.layer.borderColor = UIColor.colorWithHex("#0066FF")!.CGColor
    btn.layer.borderWidth = 1
    btn.layer.cornerRadius = 6
    btn.layer.masksToBounds = true
    
}

func addButtonCheckBox(btn:UIButton,imageNormal:UIImage,image2Selected:UIImage){
    let lLeftInset: CGFloat = 8.0
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
    btn.imageEdgeInsets = UIEdgeInsetsMake(0.0 as CGFloat, lLeftInset, 0.0 as CGFloat, 0.0 as CGFloat)
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0 as CGFloat, (lLeftInset * 2), 0.0 as CGFloat, 0.0 as CGFloat)
    btn.setImage(image2Selected, forState: UIControlState.Selected)
    btn.setImage(imageNormal, forState: UIControlState.Normal)
    btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    
}

func addButtonNewDot(btn:UIButton){
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0 as CGFloat, -btn.imageView!.width, 0.0 as CGFloat, btn.imageView!.width as CGFloat)
    btn.imageEdgeInsets = UIEdgeInsetsMake(0.0 as CGFloat, btn.titleLabel!.bounds.size.width, 0.0 as CGFloat, -btn.titleLabel!.bounds.size.width as CGFloat)
}