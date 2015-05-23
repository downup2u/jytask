//
//  GlobalTaskDataWrap.swift
//  JYTask
//
//  Created by wxqdev on 14-11-8.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation

class GlobalTaskDataWrap {
    class var shared : GlobalTaskDataWrap {
        
        struct Static {
            static let instance : GlobalTaskDataWrap = GlobalTaskDataWrap()
        }
        
        return Static.instance
    }
    
    func sendWrapMsgLoginSuccess(){
        
            var msgWrapReq = Comm.PkgPhoneCppWrapReq.builder()
            var msgWrapReply = Comm.PkgPhoneCppWrapReply.builder()
            msgWrapReq.userid = Int32(Globals.shared.userid)
            msgWrapReq.enreqtype = Comm.PkgPhoneCppWrapReq.EnReqType.PonewrapLoginsuccess
            
            var strIn = msgAPI.shared.hexStringFromData(msgWrapReq.internalGetResult.data())
            var strOut = OCWrap.getMessage(strIn)
            let hexData = msgAPI.shared.hexStringToData(strOut)

            msgWrapReply.mergeFromData(hexData)
        
    }
    
    func sendWrapMsgGetTaskUpdateTime()->String{
        var msgWrapReq = Comm.PkgPhoneCppWrapReq.builder()
        var msgWrapReply = Comm.PkgPhoneCppWrapReply.builder()
        msgWrapReq.userid = Int32(Globals.shared.userid)
        msgWrapReq.enreqtype = Comm.PkgPhoneCppWrapReq.EnReqType.PonewrapGetusertaskupdatetime
        
        var strIn = msgAPI.shared.hexStringFromData(msgWrapReq.internalGetResult.data())
        var strOut = OCWrap.getMessage(strIn)
        let hexData = msgAPI.shared.hexStringToData(strOut)

        msgWrapReply.mergeFromData(hexData)
        return msgWrapReply.lasttaskupdatetime
        
    }
    func sendWrapMsgUpdateTimeAndTasks(taskArray:Array<Comm.PkgTaskInfo>){
        
        var msgWrapReq = Comm.PkgPhoneCppWrapReq.builder()
        var msgWrapReply = Comm.PkgPhoneCppWrapReply.builder()
        msgWrapReq.userid = Int32(Globals.shared.userid)
        msgWrapReq.enreqtype = Comm.PkgPhoneCppWrapReq.EnReqType.PonewrapSetusertaskupdatetimeandtasks
        msgWrapReq.taskinfolist = taskArray
        
        var strIn = msgAPI.shared.hexStringFromData(msgWrapReq.internalGetResult.data())
        var strOut = OCWrap.getMessage(strIn)
        let hexData = msgAPI.shared.hexStringToData(strOut)

        msgWrapReply.mergeFromData(hexData)
        
        
    }
    
    func sendsendWrapMsgTaskPageQuery(msgReq:Comm.PkgTaskPageQueryReqBuilder,msgReply:Comm.PkgTaskPageQueryReplyBuilder)
    {
        var msgWrapReq = Comm.PkgPhoneCppWrapReq.builder()
        var msgWrapReply = Comm.PkgPhoneCppWrapReply.builder()
        msgWrapReq.userid = Int32(Globals.shared.userid)
        msgWrapReq.enreqtype = Comm.PkgPhoneCppWrapReq.EnReqType.PonewrapQuerypagetasks
        msgWrapReq.taskpagequeryreq = msgReq.build()
        var strIn = msgAPI.shared.hexStringFromData(msgWrapReq.internalGetResult.data())
        var strOut = OCWrap.getMessage(strIn)
        let hexData = msgAPI.shared.hexStringToData(strOut)

        msgWrapReply.mergeFromData(hexData)
        msgReply.mergeFrom(msgWrapReply.taskpagequeryreply)

    }
    
    func sendWrapMsgQueryTaskDetail(msgReq:Comm.PkgTaskQueryReqBuilder,msgReply:Comm.PkgTaskQueryReplyBuilder){
        var msgWrapReq = Comm.PkgPhoneCppWrapReq.builder()
        var msgWrapReply = Comm.PkgPhoneCppWrapReply.builder()
        msgWrapReq.userid = Int32(Globals.shared.userid)
        msgWrapReq.enreqtype = Comm.PkgPhoneCppWrapReq.EnReqType.PonewrapQuerytaskdetail
        msgWrapReq.taskqueryreq = msgReq.build()
        var strIn = msgAPI.shared.hexStringFromData(msgWrapReq.internalGetResult.data())
        var strOut = OCWrap.getMessage(strIn)
        let hexData = msgAPI.shared.hexStringToData(strOut)

        msgWrapReply.mergeFromData(hexData)
        msgReply.mergeFrom(msgWrapReply.taskqueryreply)
    }
}