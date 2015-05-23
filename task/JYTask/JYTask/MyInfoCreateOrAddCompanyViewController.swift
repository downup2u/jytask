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


        // Do any additional setup after loading the view.
        var navigationBarViewRect:CGRect = CGRectMake(0.0,0.0,0.0,0.0)
        keyboard = KeyboardManager(controller: self,navRect:navigationBarViewRect)
    }
    var keyboard:KeyboardManager!
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        keyboard.enableKeyboardManger()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        keyboard.disableKeyboardManager()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        keyboard.endEditing()
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
                    var closeStr:String = NSLocalizedString("OK", comment:"确定")
//                    let alert = SCLAlertView()
//                    alert.showTitleWithAction(okString, duration:0.0,completeText:closeStr,style: .Success,action:{
//                        alert.hideView()
//                        self.navigationController?.popViewControllerAnimated(true)
//                    })
                    
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
                SCLAlertView().showError("", subTitle: errString, closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
                
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
                    var closeStr:String = NSLocalizedString("OK", comment:"确定")
//                    let alert = SCLAlertView()
//                    alert.showTitleWithAction(self, title:"", subTitle:okString, duration:0.0,completeText:closeStr,style: .Success,action:{
//                        alert.hideView()
//                        self.navigationController?.popViewControllerAnimated(true)
//                    })

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
                SCLAlertView().showError("", subTitle: errString, closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
                
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
