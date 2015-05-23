//
//  TaskSortControl.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-13.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

protocol TaskSortControlDelegate {
    func onClickSortBtnIndex(nSel:Int)
}

class TaskSortControl: UIView {

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    
    @IBOutlet var view: UIView!
    var delegate: TaskSortControlDelegate?
    
    var btnArray:Array<UIButton> = Array<UIButton>()
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }*/

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    var curSortIndex:Int = 0
    func setSortIndex(curIndex:Int,Count:Int){
        curSortIndex = curIndex
//        for var i = Count;i<btnArray.count;i++
//        {
//          //disable  btnArray[i].
//        }
        updateCurBtn()
    }
    func getSortIndex() ->Int{
        return curSortIndex
    }
    

    
    private func setup() {
        
        NSBundle.mainBundle().loadNibNamed("TaskSortControl", owner: self, options: nil)[0] as UIView
      
        self.addSubview(view)
        self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let viewsDictionary = ["view": view]
        
        let view1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let view1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        
        self.addConstraints(view1_constraint_H)
        self.addConstraints(view1_constraint_V)
        setupBtns(6)
    }
    
    
    private func setupBtns(count:Int){
        btnArray.append(btn1)
        btnArray.append(btn2)
        btnArray.append(btn3)
        btnArray.append(btn4)
        btnArray.append(btn5)
        btnArray.append(btn6)
      
        for var index = 0; index < btnArray.count; index++
        {
            btnArray[index].tag = 101 + index
            btnArray[index].addTarget(self, action: "onButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
  
        }
        curSortIndex = 0
        updateCurBtn()
    }
    @IBAction func onButtonClicked(sender: AnyObject) {
       
        curSortIndex = sender.tag-100
        updateCurBtn()
        onSelChangedBtn(curSortIndex)
    }
    
    private func updateCurBtn(){
        
        for var i = 0;i < btnArray.count;i++
        {
            var button = btnArray[i]
            if i+1 == curSortIndex
            {
                button.selected = true
            }
            else
            {
                button.selected = false
            }
        }

    }
    private func onSelChangedBtn(nSel:Int)
    {
        delegate?.onClickSortBtnIndex(nSel)
    }
}
