//
//  TaskSort.swift
//  JYTask
//
//  Created by wxqdev on 14-12-27.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation

enum EnSortFlag :Int{
    case sortNotFinished = 0
    case sortFinished = 1
    case sortList = 2
}

func sortTaskArrayWithSortFlag(inout arrayTask:Array<Comm.PkgTaskInfo>,sortFlag:EnSortFlag){
    switch(sortFlag){
    case EnSortFlag.sortNotFinished:
        sort(&arrayTask,taskNotfinishedComparable)
    case EnSortFlag.sortFinished:
        sort(&arrayTask,taskFinishedComparable)
    case EnSortFlag.sortList:
        sort(&arrayTask,taskListComparable)
    default:
        break
    }
}


 func taskFinishedComparable(taskinfo1:Comm.PkgTaskInfo,taskinfo2:Comm.PkgTaskInfo)->Bool{
    println("taskFinishedComparable")
    println("\(taskinfo1.description)")
    println("\(taskinfo2.description)")
    return taskinfo1.updatetime > taskinfo2.updatetime;
}

 func taskListComparable(taskinfo1:Comm.PkgTaskInfo,taskinfo2:Comm.PkgTaskInfo)->Bool{
    println("taskListComparable")
    println("\(taskinfo1.description)")
    println("\(taskinfo2.description)")
    if(taskinfo1.status != taskinfo2.status){
        return taskinfo1.status.rawValue < taskinfo2.status.rawValue
    }
    if(taskinfo1.createtime != taskinfo2.createtime){
        return taskinfo1.createtime > taskinfo2.createtime
    }
    return true;
}
 func taskNotfinishedComparable(taskinfo1:Comm.PkgTaskInfo,taskinfo2:Comm.PkgTaskInfo)->Bool{
    println("taskNotfinishedComparable")
    println("\(taskinfo1.description)")
    println("\(taskinfo2.description)")
    if(taskinfo1.sortflag == 0 && taskinfo2.sortflag == 0){
        return taskinfo1.createtime < taskinfo2.createtime
    }
    if(taskinfo1.sortflag == 0 ){
        return false
    }
    if(taskinfo2.sortflag == 0){
        return true
    }
    
    return taskinfo1.sortflag < taskinfo2.sortflag;
}