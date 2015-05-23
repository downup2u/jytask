//
//  DataPicker.swift
//  iDoctors
//
//  Created by Valerio Ferrucci on 30/09/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import UIKit

public class PopDatePicker : NSObject, UIPopoverPresentationControllerDelegate, DataPickerViewControllerDelegate {
    
    public typealias PopDatePickerCallback = (newDate : NSDate, sourceView : UIView)->()
    
    var datePickerVC : PopDateViewController
    var popover : UIPopoverPresentationController?
    var sourceView : UIView!
    var dataChanged : PopDatePickerCallback?
    var presented = false
    var offset : CGFloat = 8.0
    func setOnlyTodayAfter(var isOnlyTodayAfter:Bool){
        datePickerVC.onlyTodayAfter = isOnlyTodayAfter
    }
    public init(sourceView: UIView) {
        
        var storyBoard = UIStoryboard(name:"TaskControl",bundle:nil)
        datePickerVC = storyBoard.instantiateViewControllerWithIdentifier("datePickerVC") as! PopDateViewController
        self.sourceView = sourceView
        super.init()
    }
    
    public func pick(inViewController : UIViewController, initDate : NSDate?, dataChanged : PopDatePickerCallback) {
        
        if presented {
            return  // we are busy
        }
        var v:Int = DeviceInfo.systemVersion()
        self.datePickerVC.currentDate = initDate
        self.dataChanged = dataChanged
        self.datePickerVC.delegate = self
        println("v:\(v)")
        if v >= 8
        {
            self.datePickerVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            self.datePickerVC.preferredContentSize = CGSizeMake(300,320)
            
            popover = self.datePickerVC.popoverPresentationController
            if let _popover = popover {
                _popover.sourceView = self.sourceView
                _popover.sourceRect = CGRectMake(self.offset,self.sourceView.bounds.size.height,0,0)
                _popover.delegate = self
                
                inViewController.presentViewController(datePickerVC, animated: true, completion: nil)
                presented = true
            }
        }
        else{
            inViewController.presentViewController(datePickerVC, animated: true, completion: nil)
            presented = true
        }
    }
    
    public func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        
        return .None
    }
    
    func datePickerVCDismissed(date : NSDate?) {
        
        if let _dataChanged = dataChanged {
            
            if let _date = date {
            
                _dataChanged(newDate: _date, sourceView: self.sourceView)
        
            }
        }
        presented = false
    }
}
