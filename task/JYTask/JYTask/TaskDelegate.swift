//
//  TaskDelegate.swift
//  JYTask
//
//  Created by wxqdev on 14-10-22.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation


protocol TaskChooseDelegate :class{
    func onTaskChoosed(taskbuilder:Comm.PkgTaskInfo)
}

protocol TaskUserChooseDelegate:class{
    func onUserChoosed(userid:Int32,username:String)
}