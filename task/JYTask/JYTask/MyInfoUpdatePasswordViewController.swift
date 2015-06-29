//
//  MyInfoUpdatePasswordViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-8.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class MyInfoUpdatePasswordViewController: UIViewController,UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonCorner_OK(btnok)
        // Do any additional setup after loading the view.
        let revealButton1 = addSecureTextSwitcher(self.oldpasswordField!,UIImage(named: "visible-text")!)
        revealButton1.addTarget(self, action: "didClickPasswordReveal1", forControlEvents: UIControlEvents.TouchUpInside)
        let revealButton2 = addSecureTextSwitcher(self.newpasswordField!,UIImage(named: "visible-text")!)
        revealButton2.addTarget(self, action: "didClickPasswordReveal2", forControlEvents: UIControlEvents.TouchUpInside)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickReturn(sender: AnyObject) {
        //发送PkgUserSetReq消息
        
        navigationController?.popViewControllerAnimated(true)
    }

    
    @IBOutlet weak var newpasswordField: UITextField!
    @IBOutlet weak var oldpasswordField: UITextField!
    @IBOutlet weak var btnok: UIButton!
    func didClickPasswordReveal1() {
        self.oldpasswordField.secureTextEntry = !self.oldpasswordField.secureTextEntry
    }
    func didClickPasswordReveal2() {
        self.newpasswordField.secureTextEntry = !self.newpasswordField.secureTextEntry
    }
    @IBAction func onClickOK(sender: AnyObject) {
        if(count(newpasswordField.text) < 6){
            var errString:String = "密码必须大于6个字符"
            showWarning("", errString)
            return
        }
        
        var msgReq = Comm.PkgUserSetReq.builder()
        msgReq.gettype = Comm.EnGetType.GtPhone
        msgReq.phonenumber = Globals.shared.phonenumber
        msgReq.password = oldpasswordField.text
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
                if(msgReply.issuccess){
                    var okString = "修改密码成功"
                    var closeStr:String = NSLocalizedString("OK", comment:"确定")
                    showSuccess("", okString)
                    self.navigationController?.popViewControllerAnimated(true)

                    return
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
