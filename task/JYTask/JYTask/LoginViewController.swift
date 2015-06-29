//
//  LoginViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-9-29.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var accoutField: UITextField!
    @IBOutlet weak var passwordField: UITextField!


    @IBAction func onClickLogin(sender: AnyObject) {
        if(count(accoutField.text) == 0){
            var errString:String = "账号不能为空"
            showWarning("",errString)
            return
        }
        if(count(passwordField.text) == 0){
            var errString:String = "密码不能为空"
            showWarning("", errString)
            return
        }
        var msgReq = Comm.PkgUserLoginReq.builder()
        msgReq.gettype = Comm.EnGetType.GtPhone
        msgReq.phonenumber = accoutField.text
        msgReq.password = passwordField.text
        var msgReply = Comm.PkgUserLoginReply.builder()
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
                    
                    Globals.shared.saveLogin(msgReq)
                    Globals.shared.saveLoginReply(msgReply)
                    var appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDel.setAppviewAsRootView()
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
//    func textFieldShouldReturn(textField: UITextField!) -> Bool {
//        textField.resignFirstResponder()
//        return false
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        addButtonCorner_OK(loginButton)
        addButtonCorner_Normal(registerButton)
        
        addPaddedLeftView(self.accoutField!,UIImage(named: "regname")!)
        addPaddedLeftView(self.passwordField!,UIImage(named: "regpsw")!)
        addButtonCheckBox(remembermeButton,UIImage(named: "loginRememberPwd")!,UIImage(named: "loginRememberPwdChecked")!)
        
        self.isRememberedMe = Globals.shared.getRememberMe()
        remembermeButton.selected = isRememberedMe
        
        var msgReq = Globals.shared.getLogin()
        accoutField.text = msgReq.phonenumber
        if isRememberedMe{
            passwordField.text = msgReq.password
        }

        if(Globals.shared.isLogoutAlert){
            showWarning("","你已在别处登录")
            Globals.shared.isLogoutAlert = false
        }
        

    }
    
   
 
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var remembermeButton: UIButton!

    @IBOutlet weak var forgotpasswordButton: UIButton!
    
    
    func didClickPasswordReveal() {
        passwordField.secureTextEntry = !passwordField.secureTextEntry
    }


    
    var isRememberedMe = false
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func onClickRememberMe(sender: AnyObject) {
        isRememberedMe = !isRememberedMe
        remembermeButton.selected = isRememberedMe
        Globals.shared.setRememberMe(isRememberedMe)
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
