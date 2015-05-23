//
//  MyInfoCompanyInfoViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-17.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class MyInfoCompanyInfoAdminViewController: UIViewController,TaskUserChooseDelegate {

    @IBOutlet weak var btnTransfer: UIButton!
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var btnMember: UIButton!
    @IBOutlet weak var labelCreateTime:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = Globals.shared.companyname
        // Do any additional setup after loading the view.
        addButtonCorner_OK(btnTransfer)
        addButtonCorner_Red(btnDismiss)
        addButtonCorner_Red(btnExit)
        
        refreshData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func onDataChanged(notification: NSNotification){
        var strtype: String = notification.object as! String
        if strtype == "companyinfo" {
            refreshData()
        }
    }
    
    func refreshData(){
        btnMember.setTitle("\(Globals.shared.companynumber)",forState:UIControlState.Normal)
        labelCreateTime.text = Globals.shared.companycreatetime
        if Globals.shared.isAdmin() {
            btnExit.hidden = true
            if(Globals.shared.companynumber > 1){
                btnTransfer.hidden = false
                btnDismiss.hidden = false
            }
            else{
                btnTransfer.hidden = true
                btnDismiss.hidden = false
            }
        }
        else{
            btnExit.hidden = false
            btnTransfer.hidden = true
            btnDismiss.hidden = true
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickTransPermission(sender: AnyObject) {
        
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var taskmembervc = storyBoardTask.instantiateViewControllerWithIdentifier("memberchoose") as! TaskChooseMembersViewController
        taskmembervc.delegate = self
        navigationController?.pushViewController(taskmembervc,animated: true)
    }
    
    func onUserChoosed(userid:Int32,username:String){
        if(userid == 0){
            SCLAlertView().showNotice("", subTitle: NSLocalizedString("SelectMember", comment:"请选择人员"), closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
            return

        }
        var msgReq = Comm.PkgUserReassignAdminReq.builder()
        msgReq.adminuserid = userid
        var msgReply = Comm.PkgUserReassignAdminReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                //  let msgReply:PkgUserLoginReplyBuilder = msg  as PkgUserLoginReplyBuilder
                if(msgReply.issuccess){
                    var permissionroleid = Int(msgReply.permissionroleid)
                    var rolename = msgReply.rolename
                    Globals.shared.transferRole(userid,permissionroleid:permissionroleid,rolename:rolename)

                    NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "memberrole")
                 //  self.navigationController?.popViewControllerAnimated(true)
                    var okString = "转移给\(username)成功"
                    SCLAlertView().showSuccess("", subTitle: okString, closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
                    
                    if Globals.shared.isAdmin() {
                        self.btnExit.hidden = true
                        if(Globals.shared.companynumber > 1){
                            self.btnTransfer.hidden = false
                            self.btnDismiss.hidden = false
                        }
                        else{
                            self.btnTransfer.hidden = true
                            self.btnDismiss.hidden = false
                        }
                    }
                    else{
                        self.btnExit.hidden = false
                        self.btnTransfer.hidden = true
                        self.btnDismiss.hidden = true
                    }

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
    
    func dismisscompany() {
        var msgReq = Comm.PkgUserExitCompanyReq.builder()
        msgReq.encmd = Comm.PkgUserExitCompanyReq.EnCmd.CmdDismiss
        var msgReply = Comm.PkgUserExitCompanyReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                //  let msgReply:PkgUserLoginReplyBuilder = msg  as PkgUserLoginReplyBuilder
                if(msgReply.issuccess){
                    Globals.shared.exitCompany()
                    NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "companyinfo")
                    
                    var okString = "解散组织成功"
                    var closeStr:String = NSLocalizedString("OK", comment:"确定")
//                    let alert = SCLAlertView()
//                    alert.showTitleWithAction("", subTitle:okString, duration:0.0,completeText:closeStr,style: .Success,action:{
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
                SCLAlertView().showError( "", subTitle: errString, closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
            }
            
        })

    }
    @IBAction func onClickDismiss(sender: AnyObject) {
        let alert = SCLAlertView()
        alert.addButton(NSLocalizedString("OK", comment:"确定"), target:self, selector:Selector("dismisscompany"))
        alert.showWarning("", subTitle: "你确信要解散该组织吗?该操作不能恢复", closeButtonTitle:NSLocalizedString("Cancel", comment:"取消"))
      
    }
    
    func exitcompany(){
        var msgReq = Comm.PkgUserExitCompanyReq.builder()
        msgReq.encmd = Comm.PkgUserExitCompanyReq.EnCmd.CmdExit
        var msgReply = Comm.PkgUserExitCompanyReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                //  let msgReply:PkgUserLoginReplyBuilder = msg  as PkgUserLoginReplyBuilder
                if(msgReply.issuccess){
                    Globals.shared.exitCompany()
                    NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "companyinfo")
                    var okString = "退出组织成功"
                    var closeStr:String = NSLocalizedString("OK", comment:"确定")
//                    let alert = SCLAlertView()
//                    alert.showTitleWithAction("", subTitle:okString, duration:0.0,completeText:closeStr,style: .Success,action:{
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
    @IBAction func onClickExit(sender: AnyObject) {
        let alert = SCLAlertView()
        alert.addButton("确定", target:self, selector:Selector("exitcompany"))
        alert.showWarning("", subTitle: "你确信要退出该组织吗?该操作不能恢复", closeButtonTitle:"取消")
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
