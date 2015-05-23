//
//  Checkbox.swift
//  JYTask
//
//  Created by wxqdev on 14-10-25.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit
protocol CheckboxDelegate {
    func didSelectCheckbox(state: Bool, sender: UIButton);
}
class Checkbox: UIButton {
    var mDelegate: CheckboxDelegate?
    
    required init(coder: NSCoder) {
        super.init(coder:coder);
        setup()
    }

    private func setup(){
        self.adjustEdgeInsets();
        self.applyStyle();
        
        // self.setTitle("", forState: UIControlState.Normal);
        self.addTarget(self, action: "onTouchUpInside:", forControlEvents: UIControlEvents.TouchUpInside);
    }
    
//    override  init(frame: CGRect, title: String, selected: Bool) {
    override  init(frame: CGRect){
        super.init(frame: frame);
        
    }
    
    func adjustEdgeInsets() {
        let lLeftInset: CGFloat = 8.0;
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
        self.imageEdgeInsets = UIEdgeInsetsMake(0.0 as CGFloat, lLeftInset, 0.0 as CGFloat, 0.0 as CGFloat);
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0 as CGFloat, (lLeftInset * 2), 0.0 as CGFloat, 0.0 as CGFloat);
    }
    
    func applyStyle() {
        self.setImage(UIImage(named: "loginRememberPwd"), forState: UIControlState.Selected);
        self.setImage(UIImage(named: "loginRememberPwdChecked"), forState: UIControlState.Normal);
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
    }
    
    func onTouchUpInside(sender: UIButton) {
        self.selected = !self.selected;
        mDelegate?.didSelectCheckbox(self.selected, sender:sender);
    }
}
