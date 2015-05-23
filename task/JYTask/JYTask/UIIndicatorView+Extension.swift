//
//  UIIndicatorView+Extension.swift
//  JYTask
//
//  Created by wxqdev on 14-10-30.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {
    
    private struct SubStruct {
        static var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    }
    
    class func showIndicatorInView(view: UIView) {
        SubStruct.indicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        SubStruct.indicator.frame = view.bounds
        view.addSubview(SubStruct.indicator)
        SubStruct.indicator.startAnimating()
    }
    
    class func hideIndicatorInView(view: UIView) {
        SubStruct.indicator.removeFromSuperview()
        SubStruct.indicator.stopAnimating()
    }
}