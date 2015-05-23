//
//  TaskViewDetailTaskViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-17.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

enum TaskEnum{
    case TaskSendOther
    case TaskRecvOther
    case TaskSendMySelf
}

class TaskDetailViewController: UIViewController {


    private func getTaskEnum()->TaskEnum{
        if  self.taskinfo.coworkid > 0{
            if Int(self.taskinfo.accepteduserid) == Globals.shared.userid{
                return TaskEnum.TaskRecvOther
            }
            
            return TaskEnum.TaskSendOther
        }
        return TaskEnum.TaskSendMySelf
        
    }
 
    
    var taskinfo:Comm.PkgTaskInfo = Comm.PkgTaskInfo()
    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonCorner_Red(btnDelete)
        addButtonCorner_OK(btnAccept)
        addButtonCorner_Red(btnDeny)
        self.btnAccept.hidden = true
        self.btnDeny.hidden = true
        self.btnDelete.hidden = true
        if(self.taskinfo.coworkid > 0 && self.taskinfo.isreaded == 0){
            setTaskReaded()
        }
        if(!TaskDetailInfo.isTaskEditShow(self.taskinfo, taskenum: getTaskEnum())){
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.webView.opaque = false
        self.webView.backgroundColor = UIColor.clearColor()
        
        refreshData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onDataChanged(notification: NSNotification){
        var strtype: String = notification.object as! String
        if strtype == "allmytask" {
            refreshDataNew()
        }
    }
    func refreshDataNew(){
      
        if let taskinfo = GlobalMsgReqUtil.shared.taskAllNewTaskMap[self.taskinfo.id]{
            self.taskinfo = taskinfo
            var taskHexData = msgAPI.shared.hexStringFromData(taskinfo.data())
            var taskFieldList = NSLocalizedString("TaskDetailLang",comment:"TaskFieldList");
            let nsFieldData = (taskFieldList as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            var taskFieldListHex = msgAPI.shared.hexStringFromData(nsFieldData!)
            var taskDetalHtml = OCWrap.getTaskDetailHtml(taskHexData,sLang:taskFieldListHex)
            var nsData = msgAPI.shared.hexStringToData(taskDetalHtml)
            var sHtml:String = NSString(data:nsData,encoding:NSUTF8StringEncoding)! as String
           // println("\(taskHexData),\(taskFieldListHex),\(sHtml)")
            self.webView.loadHTMLString(sHtml, baseURL: nil)
            var taskenum = self.getTaskEnum()
            btnAccept.hidden = true
            btnDeny.hidden = true
            btnDelete.hidden = true
            if taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsNew &&
                taskenum == TaskEnum.TaskRecvOther{
                    btnAccept.hidden = false
                    btnDeny.hidden = false
            }
            else if (taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsDeleted){
               btnDelete.hidden = false
            }
            
            if(taskinfo.coworkid > 0
                && Int(taskinfo.createuserid) == Globals.shared.userid
                && taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsGoing){
                    //自己发送给别人的任务,别人已接受
                    btnDelete.hidden = true
            }
        }
        
    }
    func setTaskReaded(){
        dispatch_async(dispatch_get_main_queue(),{
            var msgReq = Comm.PkgTaskOperationReq.builder()
            msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToUpdateReaded.rawValue
            msgReq.taskid = self.taskinfo.id
            msgReq.updatereaded = 1
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
                        GlobalMsgReqUtil.shared.sendNotifyReq(Comm.EnUpdatedFlag.UfMytask.rawValue)
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
//                if(bError){
//                    SCLAlertView().showError(self, title: "", subTitle: errString, closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
                
//                }
            })
        });
    }

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDeny: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    @IBAction func onClickReturn(sender: AnyObject) {
       navigationController?.popViewControllerAnimated(true)
    }
    
    func deletetask(){
        
        var msgReq = Comm.PkgTaskOperationReq.builder()
        msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToDeleteInfo.rawValue
        msgReq.taskid = self.taskinfo.id
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
                    var okString = "删除任务\(self.taskinfo.name)成功"
                    var closeStr:String = NSLocalizedString("OK", comment:"确定")
                    let alert = SCLAlertView()
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
    @IBAction func onClickDelete(sender: AnyObject) {
        let alert = SCLAlertView()
        alert.addButton("确定", target:self, selector:Selector("deletetask"))
        alert.showWarning("", subTitle: "你确信要删除这条任务吗?该操作不能恢复", closeButtonTitle:"取消")
     
    }
    @IBAction func onClickEdit(sender: AnyObject) {
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("taskAddEdit") as! TaskAddEditViewController
        var taskUI:Int = 0
        if (Globals.shared.companynumber > 1){
            taskUI = TaskUIFlag.AssginUser.rawValue
        }
        dvc.setTask(TaskType.TaskEdit,taskUI:taskUI,taskinfo:self.taskinfo)
        navigationController?.pushViewController(dvc,animated: true)

       //  self.performSegueWithIdentifier("detailtoeditSegue",sender:nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "detailtoeditSegue"{
//            var dvc:TaskAddEditViewController = segue.destinationViewController as TaskAddEditViewController
//            var taskUI:Int = TaskUIFlag.AssginUser.rawValue
//            dvc.setTask(TaskType.TaskEdit,taskUI:taskUI,taskinfo:self.taskinfo)
//        }
//        else if segue.identifier == "todenytaskSegue"{
//            var dvc:TaskDenyViewController = segue.destinationViewController as TaskDenyViewController
//            dvc.taskinfo = self.taskinfo
//
//        }
//
//    }
    
    private func refreshData(){
      
        UIActivityIndicatorView.showIndicatorInView(view!)
        dispatch_async(dispatch_get_main_queue(),{
            var msgReq = Comm.PkgTaskQueryReq.builder()
            msgReq.queryflag = Comm.PkgTaskQueryReq.EnQueryFlag.QfTaskinfo
            msgReq.taskid = self.taskinfo.id
            var msgReply = Comm.PkgTaskQueryReply.builder()
            GlobalTaskDataWrap.shared.sendWrapMsgQueryTaskDetail(msgReq, msgReply: msgReply)
            self.taskinfo  = msgReply.taskinfo

          //  dispatch_sync(dispatch_get_main_queue(),{
                var taskHexData = msgAPI.shared.hexStringFromData(self.taskinfo.data())
                var taskFieldList = NSLocalizedString("TaskDetailLang",comment:"TaskFieldList");
                
                let nsFieldData = (taskFieldList as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                var taskFieldListHex = msgAPI.shared.hexStringFromData(nsFieldData!)
                
                var taskDetalHtml = OCWrap.getTaskDetailHtml(taskHexData,sLang:taskFieldListHex)
                var nsData = msgAPI.shared.hexStringToData(taskDetalHtml)
                var sHtml:String = NSString(data:nsData,encoding:NSUTF8StringEncoding)! as String
                println("\(taskHexData),\(taskFieldListHex),\(sHtml)")
                
                self.webView.loadHTMLString(sHtml, baseURL: nil)
                var taskenum = self.getTaskEnum()
                self.btnAccept.hidden = true
                self.btnDeny.hidden = true
                self.btnDelete.hidden = true
                if self.taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsNew &&
                    taskenum == TaskEnum.TaskRecvOther{
                        self.btnAccept.hidden = false
                        self.btnDeny.hidden = false
                }
                else if (self.taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsDeleted){
                    self.btnDelete.hidden = false
                }
                if(self.taskinfo.coworkid > 0
                    && Int(self.taskinfo.createuserid) == Globals.shared.userid
                    && self.taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsGoing){
                        //自己发送给别人的任务,别人已接受
                        self.btnDelete.hidden = true
                }
                UIActivityIndicatorView.hideIndicatorInView(self.view!)
            });
      //  });

       
    }
    @IBAction func onClickAccept(sender: AnyObject) {
        sendTaskStatus(Comm.PkgTaskInfo.EnTaskStatus.TsGoing,reason:"")
    }

    @IBAction func onClickDeny(sender: AnyObject) {
        //todenytask
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("taskDeny") as! TaskDenyViewController
        dvc.taskinfo = self.taskinfo
        navigationController?.pushViewController(dvc,animated: true)
        //self.performSegueWithIdentifier("todenytaskSegue", sender: self)

    }
    
    private func sendTaskStatus(status:Comm.PkgTaskInfo.EnTaskStatus,reason:String){

        var msgReq = Comm.PkgTaskOperationReq.builder()
        msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToUpdateStatus.rawValue
        msgReq.taskid = taskinfo.id
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
                    var okString = "接受任务\(self.taskinfo.name)成功"
                    var closeStr:String = NSLocalizedString("OK", comment:"确定")
                    let alert = SCLAlertView()
//                    alert.showTitleWithAction(self, title:"", subTitle:okString, duration:0.0,completeText:closeStr,style: .Success,action:{
//                        alert.hideView()
//                        self.navigationController?.popViewControllerAnimated(true)
//                    })
                    return;
                    
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
  
}
