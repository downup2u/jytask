//
//  msgApi.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-7.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import Foundation
//import ProtocolBuffers
import UIKit

class msgAPI{
    class var shared : msgAPI {
        
        struct Static {
            static let instance : msgAPI = msgAPI()
        }
        
        return Static.instance
    }
    
    typealias MsgResponse = (Bool,String,String?) ->Void
    var sessionId:String  = ""
    
    func sendMsg(typename:String,msgReq:GeneratedMessage,block:MsgResponse){
        self.sendMsgOnce(typename,msgReq:msgReq,block:{
            (isOK:Bool,rettypename:String,rethexdata:String?) ->Void in
            if ( rettypename == "dberror"){
                 self.sendMsgOnce(typename,msgReq:msgReq,block: {
                                (isOK:Bool,rettypename:String,rethexdata:String?) ->Void in
                                
                                    block(isOK,typename,rethexdata)
                                })

            }
            else if( rettypename == "sessionlogout")
            {
                Globals.shared.isLogoutAlert = true
                var appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDel.setLoginViewAsRootView()

            }
            else if ( rettypename == "sessiontimeout"){
                //重新发送一次login请求
                self.sessionId = ""
                var loginreq = Globals.shared.getLogin()
                self.sendMsgOnce("comm.PkgUserLoginReq",msgReq:loginreq.internalGetResult,block: {
                    (isOK:Bool,rettypename:String,rethexdata:String?) ->Void in
                    if(isOK){
                        var msgReply = Comm.PkgUserLoginReply.builder()
                        let hexData = self.hexStringToData(rethexdata!)
                        msgReply.mergeFromData(hexData)
                        
                        if(msgReply.issuccess){
                        //重新发送一次
                            self.sendMsgOnce(typename,msgReq:msgReq,block: {
                                (isOK:Bool,rettypename:String,rethexdata:String?) ->Void in
                                
                                    block(isOK,typename,rethexdata)
                                })
                        }
                        else{
                            block(false,"sessiontimeout","loginerror")
                        }
                    }
                    else{
                        block(isOK,rettypename,rethexdata)
                    }
                })

            }
            else
            {
                block(isOK,rettypename,rethexdata)
            }
        })
    }
    
    private func sendMsgOnce(typename:String,msgReq:GeneratedMessage,block:MsgResponse){
        var hexData = self.hexStringFromData(msgReq.data())
        var params = "typename=\(typename)&hexdata=\(hexData)"
       
        var url:NSURL = NSURL(string:Globals.shared.urlWebService)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        request.HTTPMethod  = "POST"
        if(sessionId != "")
        {
            request.addValue(sessionId,forHTTPHeaderField:"Cookie")
            
        }//  request.addValue("application/json",forHTTPHeaderField:"Content-Type")
        let data = (params as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = data
        request.timeoutInterval = 10.0
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response,data,error) -> Void in
           // println("--->\(data)")
            if let err = error {
                block(false,error.domain,NSLocalizedString("NetworkConnectionError", comment:"网络连接错误"))
            }
            else if(response.MIMEType == "application/json"
                || response.MIMEType == "text/json"){
                var jsonData = NSJSONSerialization.JSONObjectWithData(data,options:NSJSONReadingOptions.MutableContainers,
                    error:nil) as! NSDictionary
                
                if jsonData.isKindOfClass(NSDictionary){
                    var rettypename = jsonData.valueForKey("rettypename") as! String
                    var rethexdata  = jsonData.valueForKey("rethexdata") as! String
                    var isok = jsonData.valueForKey("isok") as! Bool
                    
                    if(isok && rettypename == "comm.PkgUserLoginReply"){
                
                        if let httpResponse = response as? NSHTTPURLResponse {
                            for (name, value) in httpResponse.allHeaderFields {
                            
                                  if name == "Set-Cookie" {
                                    let sessionStr = value as! String
                                    if let range = sessionStr.rangeOfString("sessionKey=(.*?;)", options: .RegularExpressionSearch){
                                        self.sessionId = sessionStr.substringWithRange(range)
                                     }
                                    

                                 }
                            }
                        }
                    }
                    block(isok,rettypename,rethexdata)
                }
                else {
                    
                    block(false,NSLocalizedString("ReturnDataInvalid", comment:"返回数据错误"),NSLocalizedString("ReturnDataInvalid", comment:"返回数据错误"))
                }
            }
        })
    }
    
    private func jsonFromDictionary(jsonObj:NSDictionary) ->String{
        var error:NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(jsonObj, options: NSJSONWritingOptions(0), error: &error)
        var buffer = [UInt8](count:jsonData!.length, repeatedValue:0)
        jsonData!.getBytes(&buffer, length:jsonData!.length)
        var s:String = String(bytes:buffer,encoding:NSUTF8StringEncoding)!
        return s;
    }
    
    func hexStringFromData(data: NSData) -> String {
        var hexString = NSMutableString()
        var buffer = [UInt8](count:data.length, repeatedValue:0)
        data.getBytes(&buffer, length:data.length)
        for var i=0; i<buffer.count; i++ {
             hexString.appendFormat("%02x", buffer[i])
        }
        return hexString as String
    }

    
    func hexStringToData (string: String) -> NSData {
        // Based on: http://stackoverflow.com/a/2505561/313633
        var data = NSMutableData()
        var temp = ""
        for char in string {
            temp+=String(char)
            if(count(temp) == 2) {
                let scanner = NSScanner(string: temp)
                var value: CUnsignedInt = 0
                scanner.scanHexInt(&value)
                data.appendBytes(&value, length: 1)
                temp = ""
            }
            
        }
        return data as NSData
    }
    


  
}