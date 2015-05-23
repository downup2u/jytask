//
//  Import4Control.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-14.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit
protocol Import4ControlDelegate {
    func onClickImport4BtnIndex(nSel:Int)
}
class Import4Control: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    
    var btnArray:Array<UIButton> = Array<UIButton>()
    var curSel:Int = 0
    
    func setCurIndex(curIndex:Int32){
        curSel = Int(curIndex)
        updateCurBtn()
    }
    func getCurIndex() ->Int{
        return curSel
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    var delegate: Import4ControlDelegate?
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    private func setup() {
        
        NSBundle.mainBundle().loadNibNamed("Import4", owner: self, options: nil)[0] as! UIView
        
        self.addSubview(view)
        self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let viewsDictionary = ["view": view]
        
        let view1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let view1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        
        self.addConstraints(view1_constraint_H)
        self.addConstraints(view1_constraint_V)
        
        setupBtns()
    }

    
    private func setupBtns()
    {
        btn0.titleLabel?.numberOfLines = 2
        btn0.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        btn0.setTitle("重要\n紧急", forState: UIControlState.Normal)
        btn1.titleLabel?.numberOfLines = 2
        btn1.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        btn1.setTitle("重要\n不紧急", forState: UIControlState.Normal)
        btn2.titleLabel?.numberOfLines = 2
        btn2.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        btn2.setTitle("不重要\n紧急", forState: UIControlState.Normal)
        btn3.titleLabel?.numberOfLines = 2
        btn3.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        btn3.setTitle("不重要\n不紧急", forState: UIControlState.Normal)
        
        
        btnArray.append(btn0)
        btnArray.append(btn1)
        btnArray.append(btn2)
        btnArray.append(btn3)
        for var index = 0; index < btnArray.count; index++
        {
            btnArray[index].titleLabel?.font = UIFont.systemFontOfSize(12.0)
            btnArray[index].tag = 100 + index
            btnArray[index].addTarget(self, action: "onButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            btnArray[index].setTitleColor(UIColor.blackColor(),forState:UIControlState.Normal)
            btnArray[index].setTitleColor(UIColor.whiteColor(),forState:UIControlState.Selected)
         //   var bkImageNormal = UIImage.imageWithColor(UIColor.grayColor(),CGSize(width: 10, height: 1), false)
       //     var bkImageSelected = UIImage.imageWithColor(UIColor.redColor(),CGSize(width: 10, height: 1), false)
            btnArray[index].setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHex("#EBEBEB")), forState: UIControlState.Normal)
            btnArray[index].setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHex("#1E90FF")), forState: UIControlState.Selected)
            
            btnArray[index].layer.borderColor = UIColor.clearColor().CGColor
            btnArray[index].layer.borderWidth = 1
            btnArray[index].layer.cornerRadius = 6
            btnArray[index].layer.masksToBounds = true
            
        }
        curSel = 0
        updateCurBtn()
    }

    
    
    @IBAction func onButtonClicked(sender: AnyObject) {
        
        curSel = sender.tag-100
        updateCurBtn()
        onSelChangedBtn(curSel)
    }
    
    private func updateCurBtn(){
        
        for var i = 0;i<btnArray.count;i++
        {
            var button = btnArray[i]
            if i == curSel
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
        delegate?.onClickImport4BtnIndex(nSel)

    }

}
