//
//  MyInfoCreateOrAddCompanyViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-8.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit
class MyInfoCreateOrAddCompanyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var companyAddField: UITextField!

    @IBOutlet weak var companyCreateField: UITextField!


    
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickAdd(sender: AnyObject) {
        var msgReq = Comm.PkgUserInvitionCheckReq.builder()
        msgReq.invitioncode = self.companyAddField.text
        
        var msgReply = Comm.PkgUserInvitionCheckReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                if(msgReply.issuccess){
                    //注意：字段不够
                    Globals.shared.companyid = Int(msgReply.companyid)
                    Globals.shared.companyname = msgReply.companyname
                    Globals.shared.companynumber = Int(msgReply.companyusernumber)
                    Globals.shared.rolename = msgReply.rolename
                    Globals.shared.companycreatetime = msgReply.companycreatetime
                    Globals.shared.permissionroleid = Int(msgReply.permissionroleid)
                    NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "companyinfo")
                    GlobalMsgReqUtil.shared.sendGroupUserReq()
                    var okString = "加入组织成功"
                    showSuccess("", okString)
                    self.navigationController?.popViewControllerAnimated(true)

                    
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
            if(bError){
                    showError("", errString)
            }
        })
        

    }
    @IBAction func onClickCreate(sender: AnyObject) {
        var msgReq = Comm.PkgUserCreateCompanyReq.builder()
        msgReq.companyname = self.companyCreateField.text
       
        var msgReply = Comm.PkgUserCreateCompanyReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                if(msgReply.issuccess){
                    //注意：字段不够
                    Globals.shared.companyid = Int(msgReply.companyid)
                    Globals.shared.companyname = msgReply.companyname
                    Globals.shared.companynumber = Int(msgReply.companyusernumber)
                    Globals.shared.rolename = msgReply.rolename
                    Globals.shared.companycreatetime = msgReply.companycreatetime
                    Globals.shared.permissionroleid = Int(msgReply.permissionroleid)
                    NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "companyinfo")
                    GlobalMsgReqUtil.shared.sendGroupUserReq()
                    var okString = "新建组织成功"
                    showSuccess("", okString)
                    self.navigationController?.popViewControllerAnimated(true)


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
            if(bError){
                     showError("", errString)                
            }
        })
        

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
