//
//  Globals.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-7.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import Foundation

class Globals {
    class var shared : Globals {
        
        struct Static {
            static let instance : Globals = Globals()
        }
        
        return Static.instance
    }
    
    var groupArray = [Comm.PkgCompanyGroup()]
    var userArray = [Comm.PkgGroupUser()]
    //let taskdbqueue = dispatch_queue_create("jytaskdbqueue", DISPATCH_QUEUE_SERIAL)
    
    let urlWebService:String = "http://taskwebservice1.iteasysoft.com/devices/"
   // let urlWebService:String = "http://ios.iteasysoft.com/devices/"
    //let urlWebService:String = "http://192.168.1.199:8888/devices/"
  // let urlWebService:String = "http://192.168.1.130:5002/devices/"
    var version:String = "1.0.0"
    var isLogoutAlert:Bool = false
    var userid:Int = 0
    var realname:String = ""
    var companyname:String = ""
    var phonenumber:String = ""
    var companynumber:Int = 0
    var usercreatetime:String = ""
    var rolename:String = ""
    var companyid:Int = 0
    var companycreatetime:String = ""
    var lastestversion:String = "1.0.0"
    var lastestversiondownloadurl:String = ""
    var permissionroleid:Int = 1 //1是普通用户,2是管理员
    var tasknumbernotfinished = 0
    var tasknumberfinished = 0
    
    func logoutClearData(){
        GlobalMsgReqUtil.shared.stopTimer()
        
        self.groupArray.removeAll(keepCapacity: false)
        self.userArray.removeAll(keepCapacity: false)

        self.userid = 0
        self.realname = ""
        self.companyname = ""
        self.phonenumber = ""
        self.usercreatetime = ""
        self.rolename = ""
        self.companynumber = 0
        self.companyid = 0
        self.companycreatetime = ""
        self.permissionroleid = 0
        self.tasknumbernotfinished = 0
        self.tasknumberfinished = 0
    }
    func saveLoginReply(msgLoginReply:Comm.PkgUserLoginReplyBuilder){
        self.userid = Int(msgLoginReply.userid)
        self.realname = msgLoginReply.realname
        
        self.phonenumber = msgLoginReply.phonenumber
        self.usercreatetime = msgLoginReply.createtime
        self.rolename = msgLoginReply.rolename
        self.permissionroleid = Int(msgLoginReply.permissionroleid)
        
        self.companyname = msgLoginReply.companyinfo.companyname
        self.companynumber = Int(msgLoginReply.companyinfo.companyusernumber)
        self.companyid = Int(msgLoginReply.companyinfo.companyid)
        self.companycreatetime = msgLoginReply.companyinfo.companycreatetime
      //  dispatch_sync(dispatch_get_main_queue(),{
            GlobalTaskDataWrap.shared.sendWrapMsgLoginSuccess()
     //   });

    }
    func isAdmin()->Bool{
        return self.permissionroleid == 2
    }
    func exitCompany(){
        self.permissionroleid = 1
        self.companycreatetime = ""
        self.companyid = 0
        self.companyname = ""
        self.companynumber = 0
        self.rolename = "普通用户"
        self.groupArray.removeAll(keepCapacity: false)
        self.userArray.removeAll(keepCapacity: false)
    }
    func transferRole(touserid:Int32,permissionroleid:Int,rolename:String){
        self.permissionroleid = permissionroleid
        self.rolename = rolename
        GlobalMsgReqUtil.shared.sendGroupUserReq()
        
    }
    func setRememberMe(isRememberMe:Bool){
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(isRememberMe, forKey: "isRememberMe")
    }
    
    func getRememberMe()->Bool{
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var isRememberMe = defaults.objectForKey("isRememberMe") as? Bool
        if let b = isRememberMe{
            return b
        }
        return false
    }
    
    func saveLogin(msgLoginReq:Comm.PkgUserLoginReqBuilder){
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var hexData = msgAPI.shared.hexStringFromData(msgLoginReq.internalGetResult.data())
        defaults.setObject(hexData, forKey: "login")
    }
    
    func getLogin() -> Comm.PkgUserLoginReqBuilder{
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var hexdata = defaults.objectForKey("login") as? String
        var msgReq = Comm.PkgUserLoginReq.builder()
        if let hex = hexdata {
            let hexData = msgAPI.shared.hexStringToData(hex)
            msgReq.mergeFromData(hexData)
            
        }
        return msgReq
    }
    
    func isMyTask(var taskinfo : Comm.PkgTaskInfo)->Bool{
        var isMyTask = false
        if(self.userid == Int(taskinfo.createuserid) && taskinfo.coworkid == 0){
            isMyTask = true
        }
        
        if(self.userid == Int(taskinfo.createuserid) && taskinfo.coworkid == taskinfo.id){
            isMyTask = true
        }
        
        if(self.userid == Int(taskinfo.accepteduserid) && taskinfo.coworkid != taskinfo.id && taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsNew && taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsDeny){
            isMyTask = true
        }
        
        if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsDeleted){
            isMyTask = false
        }
        
        return isMyTask
    }

    func isCoworkTask(var taskinfo : Comm.PkgTaskInfo)->Bool{
        var isCoworkTask = false
        if(taskinfo.coworkid > 0){
            if self.userid == Int(taskinfo.accepteduserid) && taskinfo.coworkid != taskinfo.id{
                isCoworkTask = true
            }
            
            if self.userid == Int(taskinfo.createuserid) && taskinfo.coworkid == taskinfo.id{
                isCoworkTask = true
            }

        }
        if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsDeleted){
            isCoworkTask = false
        }
        return isCoworkTask
    
    }
    
    func isMyTaskNotFinished(var taskinfo : Comm.PkgTaskInfo)->Bool{
        if( taskinfo.coworkid == 0){
            if( taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsNew){
                return true
            }
            if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                return false
            }
            return true
        }
        else{
            if( taskinfo.createuserid == Int32(self.userid)){
                if( taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsNew){
                    return true
                }
                if( taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsGoing){
                    return true
                }
                if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsDeny){
                    return true
                }
                if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                    return false
                }
                return true
            }
            else if(taskinfo.accepteduserid == Int32(self.userid)){
                if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsGoing){
                    return true
                }
                if (taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                    return false
                }
                return true
            }
        }
        return true
    }
    
}