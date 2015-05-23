//
//  LoadingView.swift
//  JYTask
//
//  Created by wxqdev on 15-1-21.
//  Copyright (c) 2015年 task.iteasysoft.com. All rights reserved.
//

import Foundation


class LoadingView : UIView {
    
    class func addLoadingView(inView viewToShowIn: UIView) -> UIActivityIndicatorView {
        var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.color = UIColor.grayColor()
        activityIndicator.center = viewToShowIn.center
        activityIndicator.startAnimating()
        viewToShowIn.addSubview(activityIndicator)
        viewToShowIn.bringSubviewToFront(activityIndicator)
        
        return activityIndicator
    }
    
    class func removeLoadingView(andActivityIndicator activityIndicator: UIActivityIndicatorView) {
        activityIndicator.removeFromSuperview()
    }
    
}