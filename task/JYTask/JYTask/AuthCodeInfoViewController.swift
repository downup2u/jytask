//
//  AuthCodeInfoViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-7.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class AuthCodeInfoViewController: UIViewController {

    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnResend: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonCorner_OK(btnOK)
        addButtonCorner_Normal(btnResend)
     
       
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

    var phonenumber:String = ""
    var oldpassword:String = ""
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
       @IBOutlet weak var authcodeField: UITextField!

    
    @IBAction func onClickOK(sender: AnyObject) {
     //   self.performSegueWithIdentifier("authtoResetpasswordSegue", sender: self)
    //    return
        
        if self.authcodeField.text.isEmpty
        {
//            let alertView = UIAlertView()
//            alertView.title = "错误"
//            alertView.message = "验证码不能为空"
//            alertView.addButtonWithTitle("确定")
//            alertView.show()
            SCLAlertView().showNotice("", subTitle: NSLocalizedString("AuthCodeNotNull", comment:"验证码不能为空"), closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
            return
        }
        
        //发送PkgUserResetPasswordReq消息
        var msgReq = Comm.PkgUserResetPasswordReq.builder()
        msgReq.gettype = Comm.EnGetType.GtPhone
        msgReq.phonenumber = phonenumber
        msgReq.authcode = self.authcodeField.text
        var msgReply = Comm.PkgUserResetPasswordReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
              //  let msgReply:PkgUserResetPasswordReplyBuilder = msg  as PkgUserResetPasswordReplyBuilder
                if(msgReply.issuccess){
                    self.oldpassword = msgReply.oldpassword
                    self.performSegueWithIdentifier("authtoResetpasswordSegue", sender: self)
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
    var timer = NSTimer()
    private var elapsedTime: Int = 30
    @objc private func resendtimeout(){
        self.elapsedTime--
        if self.elapsedTime > 1{
            btnResend.enabled = false
            btnResend.titleLabel?.text = "\(self.elapsedTime)秒后再次发送"
        }
        else{
            btnResend.enabled = true
            btnResend.titleLabel?.text = "重新发送验证码"
            self.elapsedTime = 30
            self.timer.invalidate()
        }
    }

    @IBAction func onClickResendAuthcode(sender: AnyObject) {
      
        //无验证码，发送手机验证消息
        var msgReq = Comm.PkgUserGetPasswordReq.builder()
        msgReq.gettype = Comm.EnGetType.GtPhone
        msgReq.phonenumber = phonenumber
        var msgReply = Comm.PkgUserGetPasswordReply.builder()
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
                    self.elapsedTime = 30
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "resendtimeout", userInfo: nil, repeats: true)
                }
                else{
                    errString = msgReply.err
                  //  bError = true
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
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.destinationViewController is ResetPassordViewController){
            var dvc:ResetPassordViewController = segue.destinationViewController as! ResetPassordViewController
            dvc.phonenumber = phonenumber
            dvc.oldpassword = oldpassword
        }
        
    }
    
}
