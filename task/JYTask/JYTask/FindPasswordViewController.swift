//
//  FindPasswordViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-7.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class FindPasswordViewController: UIViewController {

    @IBOutlet weak var phonenumberField: UITextField!
  
    @IBOutlet weak var btnOK: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
 
        addButtonCorner_OK(btnOK)
        var navigationBarViewRect:CGRect = CGRectMake(0.0,0.0,0.0,0.0)
    }

    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickOK(sender: AnyObject) {
      //  self.performSegueWithIdentifier("findpasswordtoAuthSegue", sender: self)
     //   return
        if(count(phonenumberField.text) == 0){
            var errString:String = "手机号不能为空"
            showWarning("", errString)
            return
        }
        //findpasswordtoAuthSegue
        if !self.phonenumberField.text.isEmpty
        {
            //发送PkgUserGetPasswordReq消息
            var msgReq = Comm.PkgUserGetPasswordReq.builder()
            msgReq.gettype = Comm.EnGetType.GtPhone
            msgReq.phonenumber = self.phonenumberField.text
            var msgReply = Comm.PkgUserGetPasswordReply.builder()
            sendProtobufMsg(msgReq,msgReply,self.view,{
                (isOK:Bool,err:String?) ->Void in
                var bError = false
                var errString:String = ""
                if let errret = err{
                    errString = errret
                }
                if isOK{
                 //   let msgReply:PkgUserGetPasswordReplyBuilder = msg  as PkgUserGetPasswordReplyBuilder
                    if(msgReply.issuccess){
                        self.performSegueWithIdentifier("findpasswordtoAuthSegue", sender: self)
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.destinationViewController is AuthCodeInfoViewController){
            var dvc:AuthCodeInfoViewController = segue.destinationViewController as! AuthCodeInfoViewController
            dvc.phonenumber = phonenumberField.text
     
        }
        
    }

}
