//
//  TaskDetailInfo.swift
//  JYTask
//
//  Created by wxqdev on 14-12-24.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation
class TaskDetailInfo {
    enum TaskFieldIDEnum{
        case TaskField_Name
        case TaskField_Desc
        case TaskField_Status
        case TaskField_Import
        case TaskField_DenyReason
        case TaskField_FinishedTime
        case TaskField_TaskDate
        case TaskField_CreateUser
        case TaskField_AcceptUser
        case TaskField_ActionBtnDelete
        case TaskField_ActionBtnAccept
        case TaskField_Blank
    }
    internal init(id: TaskFieldIDEnum,taskCell:String,name1:String="",name2:String="") {
        self.FieldId = id
        self.taskCell = taskCell
        self.name1 = name1
        self.name2 = name2
        switch id{
        case TaskFieldIDEnum.TaskField_Blank:
                self.cellheight = 10
        case TaskFieldIDEnum.TaskField_Name:
                self.cellheight = 45
        case TaskFieldIDEnum.TaskField_Desc,TaskFieldIDEnum.TaskField_DenyReason:
                self.cellheight = 80
        case TaskFieldIDEnum.TaskField_ActionBtnDelete,TaskFieldIDEnum.TaskField_ActionBtnAccept:
                self.cellheight = 42
        default:
                self.cellheight = 25
            
        }
    }
    
    var FieldId:TaskFieldIDEnum
    var taskCell:String
    var name1:String
    var name2:String
    var cellheight:Int
    
    class func getImportSectionArray(inout taskLevelArray:Array<String>){
        taskLevelArray.removeAll(keepCapacity: true)
        taskLevelArray.append("重要紧急")
        taskLevelArray.append("重要不紧急")
        taskLevelArray.append("不重要紧急")
        taskLevelArray.append("不重要不紧急")
    }

    class func getImportArray(inout taskLevelArray:Array<String>){
        taskLevelArray.removeAll(keepCapacity: true)
        taskLevelArray.append("不重要不紧急")
        taskLevelArray.append("重要不紧急")
        taskLevelArray.append("不重要紧急")
        taskLevelArray.append("重要紧急")
    }
    
    class func getStatusString(status:Comm.PkgTaskInfo.EnTaskStatus)->String{
        var txtStatus = ""
        switch(status){
        case Comm.PkgTaskInfo.EnTaskStatus.TsNew:
            txtStatus = "新建"
        case Comm.PkgTaskInfo.EnTaskStatus.TsGoing:
            txtStatus = "进行中"
        case Comm.PkgTaskInfo.EnTaskStatus.TsFinished:
            txtStatus = "已完成"
        case Comm.PkgTaskInfo.EnTaskStatus.TsDeny:
            txtStatus = "已拒绝"
        case Comm.PkgTaskInfo.EnTaskStatus.TsDeleted:
            txtStatus = "已删除"
        default:
            break
        }
        return txtStatus

    }

    class func isTaskEditShow(taskinfo:Comm.PkgTaskInfo,taskenum:TaskEnum)->Bool{
        var isTaskEditShow = true

        if(taskinfo.coworkid > 0){
            if(taskenum == TaskEnum.TaskSendOther){
                //自己发送给别人，别人尚未接受
                if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsNew){
                    isTaskEditShow = false
                }
                else if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsGoing){
                    //自己发送给别人，别人已接受/部分可编辑
                    isTaskEditShow = true
                }
                else if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsDeny){
                    //自己发送给别人，别人已拒绝
                    isTaskEditShow = false
                }
                else if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                    //自己发送给别人，已完成
                    isTaskEditShow = false
                }
            }
            else if(taskenum == TaskEnum.TaskRecvOther){
                if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsNew){
                    //别人发送给自己，自己尚未接受
                    isTaskEditShow = false
                }
                else if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsGoing){
                    //别人发送给自己，自己接受的部分可编辑
                    isTaskEditShow = true
                }
                else if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsDeny){
                    //别人发送给自己，被自己拒绝的不能编辑
                    isTaskEditShow = false
                }
                else if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                    isTaskEditShow = false
                }
            }
        }
        else{//自己给自己的任务
            if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                isTaskEditShow = false
            }
        }
        return isTaskEditShow
        
    }
    
    class func fromTaskInfo(taskinfo:Comm.PkgTaskInfo,taskenum:TaskEnum,inout arrayTaskField:Array<TaskDetailInfo>){
        
        arrayTaskField.removeAll(keepCapacity: false)
        
        var taskfieldname = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_Name,taskCell: "cellName",name1: taskinfo.name)
        arrayTaskField.append(taskfieldname)
        
        if(taskinfo.content != ""){
            var taskfielddesc = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_Desc,taskCell: "cellDesc",name1: taskinfo.content)
            arrayTaskField.append(taskfielddesc)
        }
        
        if(taskinfo.remark != ""){
            var taskfieldname = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_DenyReason,taskCell: "cellDesc",name1: taskinfo.remark)
            arrayTaskField.append(taskfieldname)
        }
        
        var txtImport = ""
        var taskLevelArray = [String]()
        getImportArray(&taskLevelArray)
        
        var l :Int = Int(taskinfo.tasklevel.rawValue)
        txtImport = taskLevelArray[l]
        var taskfieldimport = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_Import,taskCell: "cellKeyValue",name1:"重要性", name2:txtImport)
        arrayTaskField.append(taskfieldimport)
        
        var txtStatus = getStatusString(taskinfo.status)
        var taskfieldstatus = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_Status,taskCell: "cellKeyValue",name1:"状态", name2:txtStatus)
        arrayTaskField.append(taskfieldstatus)
        
        
        var taskfieldcreatedate = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_TaskDate,taskCell: "cellKeyValue",name1:"任务日期", name2:taskinfo.taskdate)
        arrayTaskField.append(taskfieldcreatedate)
        
        if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
            var taskfieldfinishedtime = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_TaskDate,taskCell: "cellKeyValue",name1:"完成时间", name2:taskinfo.finishtime)
            arrayTaskField.append(taskfieldfinishedtime)
        }
        
        var taskfieldblank = TaskDetailInfo(id:TaskFieldIDEnum.TaskField_Blank,taskCell:"cellBlank")
        arrayTaskField.append(taskfieldblank)
        
        if(taskinfo.coworkid > 0){
            var taskfieldcreateusername = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_CreateUser,taskCell: "cellKeyValue",name1:"创建人", name2:taskinfo.createdrealname)
            arrayTaskField.append(taskfieldcreateusername)
            
            var taskfieldacceptusername = TaskDetailInfo(id: TaskFieldIDEnum.TaskField_AcceptUser,taskCell: "cellKeyValue",name1:"分配给", name2:taskinfo.acceptedrealname)
            arrayTaskField.append(taskfieldacceptusername)
            
            taskfieldblank = TaskDetailInfo(id:TaskFieldIDEnum.TaskField_Blank,taskCell:"cellBlank")
            arrayTaskField.append(taskfieldblank)
        }
        
        if taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsNew &&
            taskenum == TaskEnum.TaskRecvOther{
                var taskbtn2 = TaskDetailInfo(id:TaskFieldIDEnum.TaskField_ActionBtnAccept,taskCell: "cellBtn2")
                arrayTaskField.append(taskbtn2)
                
        }
        else if (taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsDeleted){
            var taskbtn1 = TaskDetailInfo(id:TaskFieldIDEnum.TaskField_ActionBtnDelete,taskCell: "cellBtn1")
            arrayTaskField.append(taskbtn1)
        }
        
    }
}