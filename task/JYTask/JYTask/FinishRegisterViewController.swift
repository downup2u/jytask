//
//  FinishRegisterViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-9-29.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class FinishRegisterViewController: UIViewController {

    var phonenumber:String = ""
    var oldpassword:String = ""
    var realname:String = ""
    @IBOutlet weak var btnOK: UIButton!
    override func viewDidLoad() {
    super.viewDidLoad()
        realnameField.text = realname

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = nil
        addPaddedLeftView(self.realnameField!,UIImage(named: "regname")!)
        addPaddedLeftView(self.newpasswordField!,UIImage(named: "regpsw")!)
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

    
    func didClickPasswordReveal() {
        self.newpasswordField.secureTextEntry = !self.newpasswordField.secureTextEntry
    }
    



    @IBOutlet weak var realnameField: UITextField!
    @IBOutlet weak var newpasswordField: UITextField!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    @IBAction func onClickFinish(sender: AnyObject) {
        
        if(count(realnameField.text) == 0){
            var errString:String = "必须输入真实姓名"
            SCLAlertView().showNotice("", subTitle: errString, closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
            return
        }
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
        msgReq.settype = Comm.PkgUserSetReq.EnSetType.StRealname.rawValue | Comm.PkgUserSetReq.EnSetType.StNewpassword.rawValue
        msgReq.realname = realnameField.text
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
               // let msgReply:PkgUserSetReplyBuilder = msg  as PkgUserSetReplyBuilder
                if(msgReply.issuccess){
                    var okString = "\(self.phonenumber)注册成功,即将返回首页,请在首页登录"
                    var closeStr:String = NSLocalizedString("OK", comment:"确定")
                   let alert = SCLAlertView()
//                   alert.showTitleWithAction(okString, duration:0.0,completeText:closeStr,style: .Success,action:{
//                        alert.hideView()
//                        self.navigationController?.popToRootViewControllerAnimated(true)
//                        
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
