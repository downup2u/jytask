//
//  FileManagerUtil.swift
//  JYTask
//
//  Created by wxqdev on 14-10-28.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit
class FileManagerUtil: NSObject {
    
    class func cachePath(fileName: String) -> String {
        var arr = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        var path = arr[0] as! String
        return "\(path)/\(fileName)"
    }
    
    class func cacheImageToPath(path:String,imageData:NSData)-> Bool {
        return imageData.writeToFile(path, atomically: true)
    }
    
    class func imageDataFromPath(path:String) -> AnyObject {
        var exist = NSFileManager.defaultManager().fileExistsAtPath(path)
        if exist {
            return UIImage(contentsOfFile: path)!
        }
        return NSNull()
    }
    
}