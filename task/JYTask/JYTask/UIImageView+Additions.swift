//
//  UIImageView+Additions.swift
//  JYTask
//
//  Created by wxqdev on 14-10-28.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setImage(urlString: String,placeHolder: UIImage?) {
        if(urlString == ""){
            self.image = placeHolder
            return
        }
        var url = NSURL(string:urlString)
        var cacheFilename = url!.lastPathComponent
        var cachePath = FileManagerUtil.cachePath(cacheFilename!)
        var image : AnyObject = FileManagerUtil.imageDataFromPath(cachePath)
        //  println(cachePath)
        if image as! NSObject != NSNull()
        {
            self.image = image as? UIImage
        }
        else
        {
            var req = NSURLRequest(URL: url!)
            var queue = NSOperationQueue();
            NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
                if (error != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            println(error)
                            self.image = placeHolder
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            
                            var image = UIImage(data: data)
                            
                            self.image = image
                            FileManagerUtil.cacheImageToPath(cachePath,imageData:data)
                            
                    })
                }
            })
            
        }
        
        
    }}