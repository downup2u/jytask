//
//  ChooseDatePopup.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-13.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class ChooseDatePopup: UIView {

    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var cancelbn: UIButton!
    @IBOutlet weak var okbn: UIButton!
    var OkCallBack:((date:NSDate!)->Void)?
    
    @IBAction func doCancle(sender: AnyObject) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDidStopSelector("closed")
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
        UIView.setAnimationDuration(0.5)
        self.alpha=0
        UIView.commitAnimations()
    }
    func closed()
    {
        self.removeFromSuperview()
    }
    func ShowUp(callback:((date:NSDate!)->Void)?=nil)
    {
        let mainwindow = UIApplication.sharedApplication().keyWindow
        self.alpha=0
        self.OkCallBack = callback
        mainwindow!.addSubview(self)
        self.date.minimumDate=NSDate()
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
        UIView.setAnimationDuration(0.5)
        self.alpha=1.0
        UIView.commitAnimations()
    }
    @IBAction func doOK(sender: AnyObject) {
        if (self.OkCallBack != nil){
            self.OkCallBack!(date: self.date.date)
        }
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDidStopSelector("closed")
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
        UIView.setAnimationDuration(0.5)
        self.alpha=0
        UIView.commitAnimations()
    }
}
