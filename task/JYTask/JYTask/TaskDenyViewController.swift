//
//  TaskDenyViewController.swift
//  JYTask
//
//  Created by wxqdev on 14-12-3.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

class TaskDenyViewController: UIViewController ,UITextViewDelegate{

    var isObserving :Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonCorner(btnOK)
        
        textReason.backgroundColor = UIColor.whiteColor()
        textReason.layer.borderColor = UIColor.colorWithHex("#CCCCCC")?.CGColor;
        textReason.layer.borderWidth = 1
        textReason.layer.cornerRadius = 8.0
        textReason.contentInset = UIEdgeInsetsMake(-7.0,0.0,0.0,0.0)
        
        self.webView.opaque = false
        self.webView.backgroundColor = UIColor.clearColor()
        
        taskToUI()
        // Do any additional setup after loading the view.
        self.textReason.delegate = self;
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardObservers()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.unregisterKeyboardObservers()
    }
    
    var taskinfo:Comm.PkgTaskInfo = Comm.PkgTaskInfo()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func registerKeyboardObservers(){
        if(!isObserving){
            NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
            isObserving = true
        }
    }
    
    func unregisterKeyboardObservers() {
        if(isObserving){
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardWillShowNotification", object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardWillHideNotification", object: nil)
            isObserving = false
        }
    }
    func keyboardWillShow(notification :NSNotification){
        let keyboardAnimationDetail = notification.userInfo!
        let duration = keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let keyboardFrame = (keyboardAnimationDetail[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationCurve = keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let keyboardHeight = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) ? CGRectGetHeight(keyboardFrame) : CGRectGetWidth(keyboardFrame)
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(animationCurve), animations: { () -> Void in
            let transform = CGAffineTransformMakeTranslation(0, -keyboardHeight)
            self.view.transform = transform
            }, completion: {(finished) -> () in
        })
    }
    
    func keyboardWillHide(notification :NSNotification){
        let keyboardAnimationDetail = notification.userInfo!
        let duration = keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        UIView.animateWithDuration(duration,animations: { () -> Void in
            self.view.transform = CGAffineTransformIdentity
            }, completion: {(finished) -> () in
        })
    }
    
    // MARK:UITextViewDelegate
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
    }

//    func textViewDidChange(textView: UITextView) {
//        var maxHeight:CGFloat = 80.0 // 高さを広げる上限
//        var currentHeight:CGFloat = textView.frame.size.height //現在の高さ
//        if(textView.frame.size.height < maxHeight){
//            var size:CGSize = textView.sizeThatFits(textView.frame.size)
//            constraintTextViewHeight.constant = size.height
//        }
//    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        textReason.scrollRangeToVisible(textView.selectedRange)
        return true
    }
    
    
    @IBAction func tapSendButton(sender: AnyObject) {
        textReason.resignFirstResponder()
    }
    

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var btnOK: UIButton!

    @IBOutlet weak var textReason: UITextView!
    
    private func taskToUI(){
        var taskHexData = msgAPI.shared.hexStringFromData(taskinfo.data())
        var taskFieldList = NSLocalizedString("TaskDetailLang",comment:"TaskFieldList");
        let nsFieldData = (taskFieldList as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        var taskFieldListHex = msgAPI.shared.hexStringFromData(nsFieldData!)
        var taskDetalHtml = OCWrap.getTaskDetailHtml(taskHexData,sLang:taskFieldListHex)
        var nsData = msgAPI.shared.hexStringToData(taskDetalHtml)
        var sHtml:String = NSString(data:nsData,encoding:NSUTF8StringEncoding)! as String
        println("\(taskHexData),\(taskFieldListHex),\(sHtml)")
        self.webView.loadHTMLString(sHtml, baseURL: nil)
    }
    @IBAction func onClickOK(sender: AnyObject) {
        if textReason.text == ""{
            showWarning( "", "拒绝理由不能为空")
            return
        }
        
        self.sendTaskStatus(Comm.PkgTaskInfo.EnTaskStatus.TsDeny,reason:textReason.text)
        
    }
    
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private func sendTaskStatus(status:Comm.PkgTaskInfo.EnTaskStatus,reason:String){
        btnOK.enabled = false
        var msgReq = Comm.PkgTaskOperationReq.builder()
        msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToUpdateStatus.rawValue
        msgReq.taskid = self.taskinfo.id
        msgReq.updatestatus = status.rawValue
        msgReq.reason = reason
        var msgReply = Comm.PkgTaskOperationReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                if(msgReply.issuccess){
                    GlobalMsgReqUtil.shared.sendNotifyReq(Comm.EnUpdatedFlag.UfMytask.rawValue|Comm.EnUpdatedFlag.UfMytaskfinishednumbers.rawValue)
                    var okString = "拒绝任务\(self.taskinfo.name)成功"
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
            self.btnOK.enabled = true
        })
        

        
        
        
    }

}
