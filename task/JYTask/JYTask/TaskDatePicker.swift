//
//  TaskDatePicker.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-13.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit
protocol TaskDatePickerDelegate : class {
    
    func datePickerChanged(date : String)
    func onClickSelDate()
    func onClickAddTask()
}

class TaskDatePicker: UIView {
   

    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnAddTask: UIButton!

    @IBOutlet var view: UIView!
    @IBOutlet weak var btnPickDate: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    weak var delegate : TaskDatePickerDelegate?
    var curDate = NSDate()
    @IBAction func onClickPrevDate(sender: AnyObject) {
        curDate = curDate.add(days:-1)
        var dateString = self.curDate.formatted("yyyy-MM-dd")
        println("curdate:\(dateString)")
        btnPickDate.setTitle(dateString, forState: UIControlState.Normal)
        self.delegate?.datePickerChanged(dateString)
    }
    @IBAction func onClickNextDate(sender: AnyObject) {
        
        curDate = curDate.add(days:1)
        var dateString = self.curDate.formatted("yyyy-MM-dd")
        println("curdate:\(dateString)")
        btnPickDate.setTitle(dateString, forState: UIControlState.Normal)
        self.delegate?.datePickerChanged(dateString)
    }
    @IBAction func onClickPickDate(sender: AnyObject) {
     
        self.delegate?.onClickSelDate()
    }
    
    @IBAction func onClickAddTask(sender: AnyObject) {
        self.delegate?.onClickAddTask()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }


    func setAddTaskBtnHidden(hidden:Bool){
        btnAddTask.hidden = hidden
    }
    func setCurDate(date:NSDate){
        curDate = date
        var dateString = self.curDate.formatted("yyyy-MM-dd")
        btnPickDate.setTitle(dateString, forState: UIControlState.Normal)
        
        var todaydate = NSDate().formatted("yyyy-MM-dd")
        println("todaydate:\(todaydate),dateString:\(dateString)")
        if todaydate > dateString {//选择今天以前的日期
            btnAddTask.hidden = true
        }
        else {
            btnAddTask.hidden = false
        }
        
        self.delegate?.datePickerChanged(dateString)
    }
    
    class func nib() -> UINib {
        return UINib(nibName: "TaskDatePicker", bundle: nil)
    }
    
    private func setup() {
        
      NSBundle.mainBundle().loadNibNamed("TaskDatePicker", owner: self, options: nil)[0] as UIView
      //    let views = NSBundle.mainBundle().loadNibNamed("TaskDatePicker", owner: self, options: nil)
        self.addSubview(view)
        self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let viewsDictionary = ["view": view]
        
        let view1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let view1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        
        self.addConstraints(view1_constraint_H)
        self.addConstraints(view1_constraint_V)
        
        btnPickDate.setTitle(self.curDate.formatted("yyyy-MM-dd"), forState: UIControlState.Normal)

        var w = self.view.width
//        btnAddTask.setTitle("添加新任务",forState: UIControlState.Normal)
        btnAddTask.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
//        btnAddTask.frame = CGRectMake(self.view.width - 100 , 0, 100 - 18, 40)
       // btnAddTask.setTitle("",forState: UIControlState.Normal)
       // addButtonImage(btnAddTask,UIImage(named:"addlnk")!)
        
        btnPrev.addTarget(self, action: "onClickPrevDate:", forControlEvents: UIControlEvents.TouchUpInside)
        btnPickDate.addTarget(self, action: "onClickPickDate:", forControlEvents: UIControlEvents.TouchUpInside)
        btnNext.addTarget(self, action: "onClickNextDate:", forControlEvents: UIControlEvents.TouchUpInside)
        btnAddTask.addTarget(self, action: "onClickAddTask:", forControlEvents: UIControlEvents.TouchUpInside)
    }


    
}
