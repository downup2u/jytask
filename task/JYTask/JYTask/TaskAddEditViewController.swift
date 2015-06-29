//
//  TaskAddEditViewController.swift
//  JYTask
//
//  Created by wxqdev on 14-10-22.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit
enum TaskType{
    case TaskAdd
    case TaskEdit
    case TaskAddToEdit
}

enum TaskUIFlag:Int{
    case SelTaskButton = 1
    case AssginUser = 2
}

class TaskAddEditViewController: UIViewController, Import4ControlDelegate ,TaskChooseDelegate,TaskUserChooseDelegate{


    
    @IBOutlet weak var taskContentField: UITextView!
    @IBOutlet weak var tasknameField: UITextField!
    @IBOutlet weak var btndatefield: UIButton!
    @IBOutlet weak var btnmemberfield: UIButton!
  
    @IBOutlet weak var sortSeg: UISegmentedControl!
    @IBOutlet weak var ctrlImport4: Import4Control!

    var acceptuserid:Int32 = 0

    
    func setTask(taskType:TaskType,taskUI:Int,taskinfo:Comm.PkgTaskInfo?){
        self.tasktype = taskType
        self.taskFlagUI = taskUI
        self.taskinfo = taskinfo!

    }
    
    @IBOutlet weak var btnSaveOK: UIBarButtonItem!
    
    var taskinfo:Comm.PkgTaskInfo = Comm.PkgTaskInfo()
    var tasktype:TaskType = TaskType.TaskAdd
    var taskFlagUI:Int = 0
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   tasknameField.delegate = self;
       
      
        if tasktype == TaskType.TaskAdd || tasktype == TaskType.TaskAddToEdit{
            self.navigationItem.title = "新建任务"
        }
        else{
            self.navigationItem.title = "编辑任务"
        }
        
       // taskContentField.delegate = self
        taskContentField.backgroundColor = UIColor.whiteColor()
        taskContentField.layer.borderColor = UIColor.colorWithHex("#CCCCCC")?.CGColor;
        taskContentField.layer.borderWidth = 1
        taskContentField.layer.cornerRadius = 8.0
        taskContentField.contentInset = UIEdgeInsetsMake(-7.0,0.0,0.0,0.0)
        //taskContentField.setContentOffset(CGPointZero())
        if((self.taskFlagUI & TaskUIFlag.SelTaskButton.rawValue) > 0){
            //btnSelTask.hidden = false
            let selTaskBtn = addSecureTextSwitcher(self.tasknameField!,UIImage(named: "showMoreLnk")!)
//addTextFieldButton(self.tasknameField!,"选择任务")
            selTaskBtn.addTarget(self, action: "onClickSelTask", forControlEvents: UIControlEvents.TouchUpInside)
            
        }

        
        
        if((self.taskFlagUI & TaskUIFlag.AssginUser.rawValue) > 0){
           self.btnmemberfield.hidden = false
        }
        else{
            self.btnmemberfield.hidden = true
            
        }
        

        ctrlImport4.delegate = self


        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshDataNew(){
        if let taskinfo = GlobalMsgReqUtil.shared.taskAllNewTaskMap[self.taskinfo.id]{
           self.taskinfo = taskinfo
            var count = getDateCount(self.taskinfo.taskdate)
            if(self.tasktype == TaskType.TaskAdd || self.tasktype == TaskType.TaskAddToEdit){
                count = count+1
            }
            self.taskToUI(count)
        }

    }

    func refreshData(){
        if(self.taskinfo.id > 0){
        var msgReq = Comm.PkgTaskQueryReq.builder()
        msgReq.queryflag = Comm.PkgTaskQueryReq.EnQueryFlag.QfTaskinfo
        msgReq.taskid = self.taskinfo.id
        var msgReply = Comm.PkgTaskQueryReply.builder()
        GlobalTaskDataWrap.shared.sendWrapMsgQueryTaskDetail(msgReq, msgReply: msgReply)
            self.taskinfo = msgReply.taskinfo
        }
        var count = getDateCount(self.taskinfo.taskdate)
        if(self.tasktype == TaskType.TaskAdd || self.tasktype == TaskType.TaskAddToEdit){
            count = count+1
        }
        self.taskToUI(count)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private func getDateCount(curdate:String )->Int{
        var dateNum = 0
        if(curdate != ""){
            var msgReq = Comm.PkgTaskPageQueryReq.builder()
            msgReq.taskflag = Comm.PkgTaskPageQueryReq.EnTaskFlag.TfMytask
            msgReq.enconditon = Comm.PkgTaskPageQueryReq.EnTaskQueryCondition.TqcDatestart.rawValue |
                Comm.PkgTaskPageQueryReq.EnTaskQueryCondition.TqcDateend.rawValue
            var condition = Comm.PkgTaskPageQueryReq.PkgTaskQueryCondition.builder()
            condition.taskdatestart = curdate
            condition.taskdateend = curdate
            msgReq.pkgtaskquerycondition = condition.build()
            msgReq.pageflag = Comm.PkgTaskPageQueryReq.EnPageFlag.PReturnall
            var msgReply = Comm.PkgTaskPageQueryReply.builder()
            GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
            
            for taskinfo in msgReply.taskinfolist{
                if(Globals.shared.isMyTaskNotFinished(taskinfo)){
                    dateNum++
                }
            }
        }
        return dateNum
    }
    
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickOK(sender: AnyObject) {
        self.btnSaveOK.enabled = false
        var  taskopttxt:String = ""
        if tasknameField.text == ""{
            showWarning("", "任务名不能为空")
            return
        }
        var msgReq = Comm.PkgTaskOperationReq.builder()
        switch(self.tasktype){
        case TaskType.TaskAdd:
            taskopttxt = "新建"
            msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToInsertInfo.rawValue
        case TaskType.TaskEdit:
            taskopttxt = "编辑"
            msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToUpdateInfo.rawValue
        case TaskType.TaskAddToEdit:
            taskopttxt = "新建"
            msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToUpdateInfo.rawValue
        default:
            println("error")
        }
        toCurTaskInfo()
        msgReq.taskinfo = self.taskinfo
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
                    if(self.acceptuserid == 0){
                        GlobalMsgReqUtil.shared.sendNotifyReq(Comm.EnUpdatedFlag.UfMytask.rawValue|Comm.EnUpdatedFlag.UfMytaskfinishednumbers.rawValue);
                        var okString = "\(taskopttxt)任务\(self.tasknameField.text)成功"
                        showSuccess("", okString)
                        self.navigationController?.popViewControllerAnimated(true)
                        return
                    }
                    else{
                        self.sendCoworkTask(msgReply.taskid)
                        return
                    }

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
            showError("", errString)
            self.btnSaveOK.enabled = true

            
        })
        
    }
    
    private func sendCoworkTask(taskid:Int32){
        var  taskopttxt:String = "新建"
        if(self.tasktype == TaskType.TaskEdit){
            taskopttxt = "编辑"
        }
        var msgReq = Comm.PkgTaskOperationReq.builder()
        msgReq.taskid = taskid
        msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToInsertInfoCowork.rawValue
        msgReq.accepteduseridlist.append(acceptuserid)
        toCurTaskInfo()
        msgReq.taskinfo = self.taskinfo
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
                  
                    GlobalMsgReqUtil.shared.sendNotifyReq(Comm.EnUpdatedFlag.UfMytask.rawValue|Comm.EnUpdatedFlag.UfMytaskfinishednumbers.rawValue);
                    var okString = "\(taskopttxt)任务\(self.tasknameField.text)成功"
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
            showError("", errString)
            self.btnSaveOK.enabled = true
        })

    }
    
    func onClickSortBtnIndex(nSel:Int){
        println("TaskAddNewTaskViewController ctrlSortControl btn click:\(nSel)")
    }
    func onClickImport4BtnIndex(nSel:Int){
        println("TaskAddNewTaskViewController ctrlImport4 btn click:\(nSel)")
    }
    @IBAction func onClickSelMember(sender: AnyObject) {
        onClickSelMember()
    }
    
    @IBAction func onClickSelDate(sender: AnyObject) {
        var datetext = btndatefield.titleLabel?.text
        
        var initDate:NSDate?
        if(datetext != ""){
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            initDate = formatter.dateFromString(datetext!)
        }
        
        
        DatePickerDialog().show(title: "选择日期", doneButtonTitle: "完成", cancelButtonTitle: "取消", datePickerMode: .DateAndTime) {
            (newDate) -> Void in
            
            var taskdate = newDate.formatted("yyyy-MM-dd")
            self.btndatefield.titleLabel?.text = taskdate
            var count = self.getDateCount(taskdate)
            //新建时应该i <=，编辑时应该<
            if(self.tasktype == TaskType.TaskAdd
                || self.tasktype == TaskType.TaskAddToEdit){
                    count = count + 1
            }
            
            var curSel = count - 1
            if(taskdate == self.taskinfo.taskdate){
                curSel = self.taskinfo.sortflag == 0 ? 6:Int(self.taskinfo.sortflag) - 1
            }
            else{
                if(self.tasktype == TaskType.TaskEdit){
                    count = count + 1
                    curSel = count - 1
                }
            }
            
            self.taskWithSortFlag(count,curSel:curSel)
        }
    }
    

    
    private func taskWithSortFlag(curdatecout:Int,curSel:Int){
        //curdatecount:current enabled,curSel:current Selected,from 0
        for (var i = 0 ;i < sortSeg.numberOfSegments - 1;i++ ) {
            if( i < curdatecout){
                self.sortSeg.setEnabled(true, forSegmentAtIndex: i)
            }
            else{
                self.sortSeg.setEnabled(false, forSegmentAtIndex: i)
            }
            
        }
        
        if(curdatecout > 6){
            self.sortSeg.setEnabled(true, forSegmentAtIndex: sortSeg.numberOfSegments - 1)
        }
        else{
            self.sortSeg.setEnabled(false, forSegmentAtIndex: sortSeg.numberOfSegments - 1)
        }
        
        sortSeg.selectedSegmentIndex = curSel
    }
    
    private func taskToUI(curdatecout:Int){
         self.btndatefield.titleLabel?.text  = self.taskinfo.taskdate
        
     
        tasknameField.text = self.taskinfo.name
        taskContentField.text =  self.taskinfo.content
        var curSel = 0
        if ( self.tasktype  == TaskType.TaskAdd || self.tasktype  == TaskType.TaskAddToEdit){
            curSel = curdatecout - 1
        }
        else{
            curSel = self.taskinfo.sortflag == 0 ? 6:Int(self.taskinfo.sortflag) - 1
        }
        
        taskWithSortFlag(curdatecout,curSel:curSel)
        var index:Int32 = 0
        switch(self.taskinfo.tasklevel){
        case Comm.PkgTaskInfo.EnTaskLevel.TlImportanceArgency:
            index = 0;
        case Comm.PkgTaskInfo.EnTaskLevel.TlImportanceNotargency:
            index = 1;
        case Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceArgency:
            index = 2;
        case Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency:
            index = 3;
        default:
            break;
            
        }
        self.ctrlImport4.setCurIndex(index)

        self.btndatefield.titleLabel?.text  = self.taskinfo.taskdate
        self.btnmemberfield.titleLabel?.text = self.taskinfo.acceptedrealname
        if(self.taskinfo.coworkid > 0 && self.taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsGoing){
            tasknameField.enabled = false
            taskContentField.editable  = false
            self.btnmemberfield.enabled = false
            taskContentField.backgroundColor = UIColor.colorWithHex("#CCCCCC")!
            tasknameField.backgroundColor = UIColor.colorWithHex("#CCCCCC")!
         }
    }
    
    
    private func toCurTaskInfo(){
      
        var taskbuilder = Comm.PkgTaskInfoBuilder()
        taskbuilder.mergeFrom(self.taskinfo)
        taskbuilder.name = tasknameField.text
        taskbuilder.content = taskContentField.text
        taskbuilder.sortflag = sortSeg.selectedSegmentIndex == 6 ? 0 : Int32(sortSeg.selectedSegmentIndex) + 1
        switch(ctrlImport4.getCurIndex()){
        case 0:
            taskbuilder.tasklevel = Comm.PkgTaskInfo.EnTaskLevel.TlImportanceArgency
        case 1:
            taskbuilder.tasklevel = Comm.PkgTaskInfo.EnTaskLevel.TlImportanceNotargency
        case 2:
            taskbuilder.tasklevel = Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceArgency
        case 3:
            taskbuilder.tasklevel = Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency
        default:
            taskbuilder.tasklevel = Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency
            
        }
        taskbuilder.taskdate =  self.btndatefield.titleLabel!.text!
        taskbuilder.accepteduserid = acceptuserid
        self.taskinfo = taskbuilder.build()
    }
    
    func onTaskChoosed(taskinfo:Comm.PkgTaskInfo){
        var taskdate = self.taskinfo.taskdate
        self.taskinfo = taskinfo
        var count = getDateCount(taskdate)
        if (self.taskinfo.taskdate != taskdate){
          //日期已改，重设Flag & date
            count = count+1
            var taskbuilder = Comm.PkgTaskInfoBuilder()
            taskbuilder.mergeFrom(self.taskinfo)
            taskbuilder.sortflag = Int32(count)
            taskbuilder.taskdate = taskdate
            self.taskinfo = taskbuilder.build()
            
        }
        
        tasktype = TaskType.TaskAddToEdit
        taskToUI(count)

    }
    
    func onUserChoosed(userid:Int32,username:String){
        if(userid == 0){
            showWarning( "", NSLocalizedString("SelectMember", comment:"请选择人员"))
            return
            
        }
        self.btnmemberfield.titleLabel?.text = username
        self.acceptuserid = userid
    }
    func onClickSelMember() {
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("memberchoose") as! TaskChooseMembersViewController
        dvc.delegate = self
        navigationController?.pushViewController(dvc,animated: true)
    }
    func onClickSelTask() {
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("tasklist") as! TaskAllFinishedTaskViewController
        dvc.delegate = self
        dvc.taskFlag = TaskFlag.ChooseNotFinishedTask
        navigationController?.pushViewController(dvc,animated: true)

    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//        if segue.destinationViewController is TaskAllFinishedTaskViewController{
//            var dvc:TaskAllFinishedTaskViewController = segue.destinationViewController as TaskAllFinishedTaskViewController
//            dvc.delegate = self
//            dvc.taskFlag = TaskFlag.ChooseNotFinishedTask
//        }
//        
//        else if segue.destinationViewController is TaskChooseMembersViewController{
//            var dvc:TaskChooseMembersViewController = segue.destinationViewController as TaskChooseMembersViewController
//            dvc.delegate = self
//        }
//
//    }
 }
