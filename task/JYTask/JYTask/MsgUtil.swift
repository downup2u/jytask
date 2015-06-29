//
//  MsgUtil.swift
//  JYTask
//
//  Created by wxqdev on 14-10-30.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import Foundation
//import ProtocolBuffers
import UIKit


typealias protobufMsgResponse = (Bool,String?) ->Void

func sendProtobufMsg(msgReq:GeneratedMessageBuilder,msgReply:GeneratedMessageBuilder,view:UIView?,block:protobufMsgResponse)
{
    
    println("Start  Send-----------------------------------------")
    println(NSDate().formatted("HH:mm:ss"))
    println(msgReq.internalGetResult.description)
    
    
    var cnamereq:String = msgReq.internalGetResult.classMetaType().className()
    if cnamereq.hasPrefix("Comm."){
        var stringindex = cnamereq.rangeOfString("Comm.")
        cnamereq.replaceRange(stringindex!, with: "comm.")
        println("cnamereq is \(cnamereq)")
    }
    
    
    //var ac :UIActivityIndicatorView?
    if(view != nil){
        UIActivityIndicatorView.showIndicatorInView(view!)
        // ac = LoadingView.addLoadingView(inView: view!)
    }
    msgAPI.shared.sendMsg(cnamereq,msgReq: msgReq.internalGetResult, block: {
        (isOK:Bool,rettypename:String,rethexdata:String?) ->Void in
        
        if(view != nil){
            UIActivityIndicatorView.hideIndicatorInView(view!)
            //  LoadingView.removeLoadingView(andActivityIndicator: ac!)
        }
        
        if isOK {
            var start:String.Index = advance(cnamereq.startIndex, 0)
            var end:String.Index = advance(cnamereq.endIndex, -3)
            let range = Range(start:start,end:end)
            var cnamereply = cnamereq.substringWithRange(range)
            cnamereply += "Reply"
            

            if cnamereply.hasPrefix("comm."){
                var stringindex = cnamereply.rangeOfString("comm.")
                cnamereply.replaceRange(stringindex!, with: "Comm.")
            }
            
            if(msgReply.internalGetResult.classMetaType().className() == cnamereply)
            {
                let hexData = msgAPI.shared.hexStringToData(rethexdata!)

                msgReply.mergeFromData(hexData)
                println("Start  Recv-----------------------------------------")
                println(NSDate().formatted("HH:mm:ss"))
                println(msgReply.internalGetResult.description)
                
                block(true,nil)
                return
            }
            block(false,NSLocalizedString("ReturnDataInvalid", comment:"返回数据不符要求"))
            
        }
        else{
            block(false,rethexdata)
        }
    })
    
}

func showError(message: String, subtitle: String?) {
    var rootViewController:UIViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
    TSMessage.showNotificationInViewController(
        TSMessage.defaultViewController(),
        title: message,
        subtitle: subtitle,
        image: nil,
        type: TSMessageNotificationType.Error,
        duration: 1,
        callback: nil,
        buttonTitle: nil,
        buttonCallback: nil,
        atPosition: TSMessageNotificationPosition.NavBarOverlay,
        canBeDismissedByUser: true)
}
func showSuccess(message: String, subtitle: String?) {
    var rootViewController:UIViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
    TSMessage.showNotificationInViewController(
        TSMessage.defaultViewController(),
        title: message,
        subtitle: subtitle,
        image: nil,
        type: TSMessageNotificationType.Success,
        duration: 1,
        callback: nil,
        buttonTitle: nil,
        buttonCallback: nil,
        atPosition: TSMessageNotificationPosition.NavBarOverlay,
        canBeDismissedByUser: true)
}

func showWarning(message: String, subtitle: String?) {
    var rootViewController:UIViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
    TSMessage.showNotificationInViewController(
        TSMessage.defaultViewController(),
        title: message,
        subtitle: subtitle,
        image: nil,
        type: TSMessageNotificationType.Warning,
        duration: 1,
        callback: nil,
        buttonTitle: nil,
        buttonCallback: nil,
        atPosition: TSMessageNotificationPosition.NavBarOverlay,
        canBeDismissedByUser: true)
}