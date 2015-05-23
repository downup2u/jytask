//
//  ProtobufMsgFactory.swift
//  JYTask
//
//  Created by wxqdev on 14-10-31.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation
import ProtocolBuffers

class protoBufMsgFactory : CreateProtobufMsgProtocol {
//    class func createReplyMsg2(classname:String)-> GeneratedMessageBuilder?{
//            var aa:PkgConnectReply = PkgConnectReply()
//            var classMap:Dictionary<String,GeneratedMessage.Type> = Dictionary<String,GeneratedMessage.Type>()
//            var vclass = aa.classMetaType().className()
//            classMap[vclass] = aa.classMetaType()
//    
//            var type:GeneratedMessage.Type = classMap[vclass]!
//            let classinstance = type()
//            return classinstance.toBuider()
////        let classmap = [
////            "PkgTaskPageQueryReply":PkgTaskPageQueryReply.self,
////            "PkgUserLoginReply":PkgUserLoginReply.self,
////            "PkgUserResetPasswordReply":PkgUserResetPasswordReply.self
////        ]
////    
////        if let pclass: GeneratedMessage.Type = classmap[classname] {
////            let classinstance = pclass()
////            return classinstance.builder()
////        }
////    return nil
//    }
    
    class func createReplyMsg(classname:String) -> GeneratedMessageBuilder?{
        switch classname{
            case "PkgTaskPageQueryReply":
                return PkgTaskPageQueryReply.builder()
            case "PkgUserLoginReply":
                return PkgUserLoginReply.builder()
            case "PkgUserLoginReply":
                return PkgUserLoginReply.builder()
            case "PkgUserResetPasswordReply":
                return PkgUserResetPasswordReply.builder()
            case "PkgUserGetAuthReply":
                return PkgUserGetAuthReply.builder()
            case "PkgUserCheckReply":
                return PkgUserCheckReply.builder()
            case "PkgUserGetPasswordReply":
                return PkgUserGetPasswordReply.builder()
            case "PkgUserSetReply":
                return PkgUserSetReply.builder()
            case "PkgUserCheckInvitionCodeReply":
                return PkgUserCheckInvitionCodeReply.builder()
            case "PkgUserCreateReply":
                return PkgUserCreateReply.builder()
            
            case "PkgAdvQueryReply":
                return PkgAdvQueryReply.builder()
            default:
               println("error:\(classname)")
        }
        return nil
    }
}