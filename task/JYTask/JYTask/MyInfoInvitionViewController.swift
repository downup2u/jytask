//
//  MyInfoInvitionViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-17.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class MyInfoInvitionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonCorner_OK(btnInvition)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
  
    @IBOutlet weak var btnInvition: UIButton!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBAction func onClickInvition(sender: AnyObject) {
       if self.accountField.text == ""
       {
            showWarning("", "手机号不能为空")
            return
       }
        var msgReq = Comm.PkgUserInvitionUserReq.builder()
        msgReq.gettype = Comm.EnGetType.GtPhone
        msgReq.phonenumber = self.accountField.text
        msgReq.realname = self.nameField.text
        var msgReply = Comm.PkgUserInvitionUserReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                if(msgReply.issuccess){

                    var okString = "邀请用户成功"
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
