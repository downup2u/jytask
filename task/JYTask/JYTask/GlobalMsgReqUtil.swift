//
//  GlobalMsgReqUtil.swift
//  JYTask
//
//  Created by wxqdev on 14-11-5.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation
import UIKit

let ONGETMSGREFRESHDATA = "onGetMsgRefreshData"

class GlobalMsgReqUtil {
    class var shared : GlobalMsgReqUtil {
        
        struct Static {
            static let instance : GlobalMsgReqUtil = GlobalMsgReqUtil()
        }
        
        return Static.instance
    }
    
    private var timer = NSTimer()
    var elapsedTime:Double = 60 // 1 mins

    private func startTimer(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.elapsedTime, target: self, selector: "sendreqinterval", userInfo: nil, repeats: false)
    }
    
    func stopTimer(){
        self.timer.invalidate()
    }
    
   @objc private func sendreqinterval(){
     //   dispatch_sync(dispatch_get_main_queue(),{
            self.stopTimer()
            self.sendNotifyReq(0)
     //   });
    }
    
    func loginSuccessSendReq(){
     //   dispatch_sync(dispatch_get_main_queue(),{
            self.sendTaskTableReq()
            self.sendNotifyReq(Comm.EnUpdatedFlag.UfCompanyinfo.rawValue|Comm.EnUpdatedFlag.UfUserrole.rawValue|Comm.EnUpdatedFlag.UfMytaskfinishednumbers.rawValue|Comm.EnUpdatedFlag.UfVersion.rawValue)
            self.startTimer()
     //   });
    }
    
    func sendVersion(){
     //   dispatch_sync(dispatch_get_main_queue(),{
            self.sendNotifyReqWithFlag(Comm.EnUpdatedFlag.UfVersion)
    //   });
    }

    private func sendNotifyReqWithFlag(flag:Comm.EnUpdatedFlag){
        switch(flag){
        case Comm.EnUpdatedFlag.UfTaskcowork:
            sendTaskTableReq()
        case Comm.EnUpdatedFlag.UfMytask:
            sendTaskTableReq()
        default:
            sendNotifyReq(flag.rawValue)
            break
        }
    }
    func sendGroupUserReq(){
      //  dispatch_sync(dispatch_get_main_queue(),{
            var msgReq = Comm.PkgCompanyGroupQueryReq.builder()
            msgReq.querytype = Comm.PkgCompanyGroupQueryReq.EnQueryType.QtAll
            var msgReply = Comm.PkgCompanyGroupQueryReply.builder()
            sendProtobufMsg(msgReq,msgReply,nil,{
                (isOK:Bool,err:String?) ->Void in
                var bError = false
                var errString:String = ""
                if let errret = err{
                    errString = errret
                }
                if isOK{
                    if(msgReply.issuccess){
                        Globals.shared.groupArray.removeAll(keepCapacity: false)
                        Globals.shared.userArray.removeAll(keepCapacity: false)
                       
                        for group in msgReply.companygrouplist{
                            Globals.shared.groupArray.append(group)
                        }
                        
                        for user in msgReply.groupuserlist{
                            Globals.shared.userArray.append(user)
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "groupuser")
                      
                    }
                    else{
                        errString = msgReply.err
                        bError = true
                    }
                }
                else{
                    bError = true
                    errString = err!
                }
               
            })
      //  });
        

    }
    private var dateupdatetime = ""
    private var gflag:Int32 = 0
    func sendNotifyReq(flag2:Int32){
        gflag = gflag | flag2
       // dispatch_sync(dispatch_get_main_queue(),{
            var flag = self.gflag
            self.gflag = 0
            var msgReq = Comm.PkgNotifyReq.builder()
            msgReq.curversion = Globals.shared.version
            msgReq.platmform = "ios"
            msgReq.dataupatedtime = self.dateupdatetime
            msgReq.forceupdateflag = flag
           
            var msgReply = Comm.PkgNotifyReply.builder()
            sendProtobufMsg(msgReq,msgReply,nil,{
                (isOK:Bool,err:String?) ->Void in
                var bError = false
                var errString:String = ""
                if let errret = err{
                    errString = errret
                }
                if isOK{
                    self.dateupdatetime = msgReply.dataupatedtime
                   
                    if( (msgReply.notifyupdatedflag & Comm.EnUpdatedFlag.UfTaskcowork.rawValue) > 0){
                        self.sendTaskTableReq()
                    }
                    if( (msgReply.notifyupdatedflag & Comm.EnUpdatedFlag.UfMytask.rawValue) > 0){
                        self.sendTaskTableReq()
                    }
                    if( (msgReply.notifyupdatedflag & Comm.EnUpdatedFlag.UfCompanyinfo.rawValue) > 0){
                        Globals.shared.companyid = Int(msgReply.companyinfo.companyid)
                        Globals.shared.companyname = msgReply.companyinfo.companyname
                        Globals.shared.companynumber = Int(msgReply.companyinfo.companyusernumber)
                        Globals.shared.companycreatetime = msgReply.companyinfo.companycreatetime
                        self.sendGroupUserReq()
                        NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "companyinfo")
                    }
                    if( (msgReply.notifyupdatedflag & Comm.EnUpdatedFlag.UfMytaskfinishednumbers.rawValue) > 0){
                        Globals.shared.tasknumbernotfinished = Int(msgReply.tasknumbernotfinished)
                        Globals.shared.tasknumberfinished = Int(msgReply.tasknumberfinished)
                        NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "tasknumber")
                    }
                    if( (msgReply.notifyupdatedflag & Comm.EnUpdatedFlag.UfUserrole.rawValue) > 0){
                        Globals.shared.rolename = msgReply.rolename
                        Globals.shared.permissionroleid = Int(msgReply.permissionroleid)
                        NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "memberrole")
                    }
                    if( (msgReply.notifyupdatedflag & Comm.EnUpdatedFlag.UfVersion.rawValue) > 0){
                        Globals.shared.lastestversion = msgReply.versionlastest
                        Globals.shared.lastestversiondownloadurl = msgReply.versiondownloadurl
                        NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "latestversion")
                    }
                    
                }
                else{
                    bError = true
                    errString = err!
                }
                
                if flag == 0{
                    self.startTimer()
                }
                
            })
       // });


    }
    var taskAllNewTaskMap = Dictionary<Int32,Comm.PkgTaskInfo>()
    private func sendTaskTableReq(){
       
        var msgReq = Comm.PkgTaskPageQueryReq.builder()
        msgReq.taskflag = Comm.PkgTaskPageQueryReq.EnTaskFlag.TfTasktable
        msgReq.pageflag = Comm.PkgTaskPageQueryReq.EnPageFlag.PReturnall
        msgReq.enconditon = Comm.PkgTaskPageQueryReq.EnTaskQueryCondition.TqcLastupdatetime.rawValue
 
        var condition = Comm.PkgTaskPageQueryReq.PkgTaskQueryCondition.builder()
        condition.lastupdatetime = GlobalTaskDataWrap.shared.sendWrapMsgGetTaskUpdateTime()
  
        msgReq.pkgtaskquerycondition = condition.build()
        
        var msgReply = Comm.PkgTaskPageQueryReply.builder()
        sendProtobufMsg(msgReq,msgReply,nil,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                if(msgReply.issuccess){
                    self.taskAllNewTaskMap.removeAll(keepCapacity: false)
                    var taskAllNewTaskArray = [Comm.PkgTaskInfo()]
                    for taskinfo in msgReply.taskinfolist{
                        taskAllNewTaskArray.append(taskinfo)
                        self.taskAllNewTaskMap[taskinfo.id] = taskinfo
                    }

                    println(NSDate().formatted("HH:mm:ss"))
                    GlobalTaskDataWrap.shared.sendWrapMsgUpdateTimeAndTasks(taskAllNewTaskArray)
                    NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "allmytask")
                    NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "allcoworktask")

                }
                else{
                    errString = msgReply.err
                    bError = true
                }
                
            }
            else{
                bError = true
                errString = err!
            }
           
        })
    }

}