//
//  RegisterViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-9-29.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var phonenumberField: UITextField!
    @IBOutlet weak var invitioncodeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        addButtonCorner_OK(btnOK)
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var btnOK: UIButton!
 
    @IBAction func onClickReturn(sender: AnyObject) {
        /*
        let registerView  = self.storyboard?.instantiateViewControllerWithIdentifier("registerview") as RegisterViewController
        self.presentViewController(registerView, animated: true, completion: nil)  */
        navigationController?.popViewControllerAnimated(true)
    }
 
    @IBAction func btnRegisterOK(sender: AnyObject) {
        if self.invitioncodeField.text.isEmpty
        {
      //      self.performSegueWithIdentifier("registertoActiveSegue", sender: self)
       //     return
            //无验证码，发送手机验证消息
            var msgReq = Comm.PkgUserGetAuthReq.builder()
            msgReq.gettype = Comm.EnGetType.GtPhone
            msgReq.phonenumber = phonenumberField.text
            var msgReply = Comm.PkgUserGetAuthReply.builder()
            sendProtobufMsg(msgReq,msgReply,self.view,{
                (isOK:Bool,err:String?) ->Void in
                var bError = false
                var errString:String = ""
                if let errret = err{
                    errString = errret
                }
                if isOK{
                   // let msgReply:PkgUserGetAuthReplyBuilder = msg  as PkgUserGetAuthReplyBuilder
                    if(msgReply.issuccess){
                        self.performSegueWithIdentifier("registertoActiveSegue", sender: self)
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
        else
        {
            //有验证码，发送生成用户消息
            var msgReq = Comm.PkgUserCreateReq.builder()
            msgReq.gettype = Comm.EnGetType.GtPhone
            msgReq.phonenumber = phonenumberField.text
            msgReq.invitioncode = invitioncodeField.text
            var msgReply = Comm.PkgUserCreateReply.builder()
            sendProtobufMsg(msgReq,msgReply,self.view,{
                (isOK:Bool,err:String?) ->Void in
                var bError = false
                var errString:String = ""
                if let errret = err{
                    errString = errret
                }
                if isOK{
                  //  let msgReply:PkgUserCreateReplyBuilder = msg  as PkgUserCreateReplyBuilder
                    if(msgReply.issuccess){
                        self.realname = msgReply.realname
                        self.performSegueWithIdentifier("registertoFinishSegue", sender: self)
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
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /**/

    // MARK: - Navigation
    var realname:String = ""
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.destinationViewController is ActiveAccountViewController){
            var dvc:ActiveAccountViewController = segue.destinationViewController as! ActiveAccountViewController
            dvc.phonenumber = phonenumberField.text
        }
        else if(segue.destinationViewController is FinishRegisterViewController){
            var dvc:FinishRegisterViewController = segue.destinationViewController as! FinishRegisterViewController
            dvc.phonenumber = phonenumberField.text
            dvc.oldpassword = invitioncodeField.text
            dvc.realname = self.realname
        }
    }

}
