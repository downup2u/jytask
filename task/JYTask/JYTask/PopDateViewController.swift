//
//  DatePickerActionSheet.swift
//  iDoctors
//
//  Created by Valerio Ferrucci on 30/09/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import UIKit

protocol DataPickerViewControllerDelegate : class {
    
    func datePickerVCDismissed(date : NSDate?)
}

class PopDateViewController : UIViewController,CKCalendarDelegate{
    
    @IBOutlet var calendarView: CKCalendarView!
    
    weak var delegate : DataPickerViewControllerDelegate?
    var onlyTodayAfter = false
    var currentDate : NSDate? {
        didSet {
            updatePickerCurrentDate()
        }
    }


    private func updatePickerCurrentDate() {
        
        if let _currentDate = self.currentDate {
            if let _calendarView = self.calendarView {
                calendarView.selectDate(_currentDate,makeVisible:true)
            }
        }
    }

    func calendar(calendar: CKCalendarView, date: NSDate) -> Bool {
        self.dismissViewControllerAnimated(true){
            var selDate:NSDate? = date
            self.delegate?.datePickerVCDismissed(selDate)
        }
        return true
    }
//    func calendar(calendar: CKCalendarView, didSelectDate date: NSDate) -> Bool {
//        self.dismissViewControllerAnimated(true){
//            var selDate:NSDate? = date
//            self.delegate?.datePickerVCDismissed(selDate)
//        }
//        return true
//    }
    func calendar(calendar: CKCalendarView, willSelectDate date: NSDate) -> Bool {
        
        if(onlyTodayAfter){
            var todayDate = NSDate()
            if( todayDate.formatted("yyyy-MM-dd") > date.formatted("yyyy-MM-dd")){
                return false
            }
        }
        return true
    }
    
    @IBAction func okAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) {
          //  let nsdate = self.calendarView.
          //  let nsdate = self.datePicker.date
           // self.delegate?.datePickerVCDismissed(nsdate)
            
        }
    }
    
    override func viewDidLoad() {
        calendarView.delegate = self
        updatePickerCurrentDate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        self.delegate?.datePickerVCDismissed(nil)
    }
}
