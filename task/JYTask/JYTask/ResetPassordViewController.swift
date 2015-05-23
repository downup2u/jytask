//
//  ResetPassordViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-7.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class ResetPassordViewController: UIViewController {
    var phonenumber:String = ""
    var oldpassword:String = ""
    @IBOutlet weak var btnOK: UIButton!
   
   
    @IBOutlet weak var newpasswordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()


        addButtonCorner_OK(btnOK)
        let revealButton = addSecureTextSwitcher(self.newpasswordField!,UIImage(named: "visible-text")!)
        revealButton.addTarget(self, action: "didClickPasswordReveal", forControlEvents: UIControlEvents.TouchUpInside)
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
    @IBAction func onClickReturn(sender: AnyObject) {
         navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didClickPasswordReveal() {
        self.newpasswordField.secureTextEntry = !self.newpasswordField.secureTextEntry
    }

    @IBAction func onClickOK(sender: AnyObject) {
        if(count(newpasswordField.text) < 6){
            var errString:String = "密码必须大于6个字符"
            SCLAlertView().showNotice("", subTitle: errString, closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
            return
        }

        //发送PkgUserSetReq消息
        var msgReq = Comm.PkgUserSetReq.builder()
        msgReq.gettype = Comm.EnGetType.GtPhone
        msgReq.phonenumber = phonenumber
        msgReq.password = oldpassword
        msgReq.settype = Comm.PkgUserSetReq.EnSetType.StNewpassword.rawValue
        msgReq.newpassword = newpasswordField.text
        var msgReply = Comm.PkgUserSetReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
              //  let msgReply:PkgUserSetReplyBuilder = msg  as PkgUserSetReplyBuilder
                if(msgReply.issuccess){
                    self.performSegueWithIdentifier("toresetpasswordokSegue", sender: self)
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
