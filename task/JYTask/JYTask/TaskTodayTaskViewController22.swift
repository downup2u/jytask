//
//  TaskTodayTaskViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-10.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit
//import Snappy

class TaskTodayTaskViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,TaskDatePickerDelegate{
    
    let MaxGoingTaskNumber = 6
    var task6Array = [PkgTaskInfoBuilder]()
    var taskFinishedArray = [PkgTaskInfoBuilder]()
    var isExpand = true


    @IBOutlet weak var tableview:UITableView!
    
    var taskDatePicker: TaskDatePicker?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableview.dataSource = self
        tableview.delegate = self
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight
        self.view.autoresizesSubviews = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)

        
        tableview.registerClass(TaskDatePicker.self, forHeaderFooterViewReuseIdentifier: "TaskDatePicker")
        self.tableview.rowHeight = 44;
        self.tableview.sectionHeaderHeight = 25
        
//        taskDatePicker = TaskDatePicker(frame: CGRectMake(0,0,tableview.width,self.tableview.sectionHeaderHeight))
//        self.taskDatePicker!.delegate = self
//        self.tableview.tableHeaderView = taskDatePicker
//        popDatePicker = PopDatePicker(sourceView: taskDatePicker!)
//        
//        refreshData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onDataChanged(notification: NSNotification){
        var strtype: String = notification.object as String
        if strtype == "allmytask" {
            refreshData()
        }
    }
    var popDatePicker : PopDatePicker?

    func onClickSelDate(){
        var initDate = taskDatePicker!.curDate
        popDatePicker!.pick(self, initDate:initDate, dataChanged: {
            (newDate : NSDate, sourceView : UIView) -> () in
            
            self.taskDatePicker!.setCurDate(newDate)
            self.refreshData()
        })
    }
    
    func tableView(tableView: UITableView,viewForHeaderInSection section: Int) -> UIView?{
        if( section == 0 ){
            if self.taskDatePicker == nil{
                self.taskDatePicker = TaskDatePicker(frame: CGRectMake(0,0,tableview.width,self.tableview.sectionHeaderHeight))
                self.taskDatePicker!.delegate = self
                popDatePicker = PopDatePicker(sourceView: taskDatePicker!)
                refreshData()
            }
            
            return self.taskDatePicker!
        }
            
        return nil

   }
//    func tableView(tableView: UITableView,heightForHeaderInSection section: Int) -> CGFloat{
//        if section == 0{
//            return 25.0
//        }
//        return 45.0
//    }
//    var viewShowMore:UIView?

    override func willMoveToParentViewController(parent:UIViewController?) {
        println("TaskToday willMoveToParentViewController...\(self.view.frame),table:\(self.tableview.frame)")
    }
    
    override func didMoveToParentViewController(parent:UIViewController?) {
        println("TaskToday didMoveToParentViewController...\(self.view.frame),table:\(self.tableview.frame)")
    }
    override func viewWillLayoutSubviews(){
     //   self.tableview.frame = self.view.bounds
    }

    override func viewDidLayoutSubviews(){
        self.tableview.frame = self.view.bounds
        println("today viewDidLayoutSubviews:\(self.view.frame),\(self.tableview.frame)")
    }
    func datePickerChanged(date : String){
        var todaydate = NSDate().formatted("YYYY-MM-dd")
        taskDatePicker?.setAddTaskBtnHidden(todaydate > date)
      
        refreshData()
    }
    
    
    private func refreshData(){
        if ( taskDatePicker == nil){
            return
        }
        var date = taskDatePicker!.curDate.formatted("YYYY-MM-dd")
        task6Array.removeAll(keepCapacity: true)
        taskFinishedArray.removeAll(keepCapacity: true)
        var msgReq = PkgTaskPageQueryReq.builder()
        msgReq.taskflag = PkgTaskPageQueryReq.EnTaskFlag.TfMytask
        msgReq.enconditon = PkgTaskPageQueryReq.EnTaskQueryCondition.TqcDatestart.rawValue |
            PkgTaskPageQueryReq.EnTaskQueryCondition.TqcDateend.rawValue
        var condition = PkgTaskPageQueryReq.PkgTaskQueryCondition.builder()
        condition.taskdatestart = date
        condition.taskdateend = date
        msgReq.pkgtaskquerycondition = condition.build()
        msgReq.pageflag = PkgTaskPageQueryReq.EnPageFlag.PReturnall
        var msgReply = PkgTaskPageQueryReply.builder()
        GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
        
        for taskinfo in msgReply.taskinfolist{
            var taskbuilder = PkgTaskInfo.builder()
            taskbuilder.mergeFrom(taskinfo)
            if(Globals.shared.isMyTaskNotFinished(taskbuilder)){
                self.task6Array.append(taskbuilder)
            }
            else {
                if( taskbuilder.status != PkgTaskInfo.EnTaskStatus.TsDeleted){
                    self.taskFinishedArray.append(taskbuilder)
                }
            }

        }
        tableview.reloadData()
        
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell?
        var islastrow = false
        

        var celltask : AnyObject! = tableView.dequeueReusableCellWithIdentifier("celltask")
        var   labelnumber = celltask.viewWithTag(1000) as UILabel
        var   imageview = celltask.viewWithTag(1001) as UIImageView
        var   labelname = celltask.viewWithTag(1002) as UILabel
        var   checkbtn = celltask.viewWithTag(1003) as UIButton
        checkbtn.addTarget(self, action: "onCheckButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        checkbtn.layer.setValue(indexPath.row, forKey: "taskindex")
        
        if(indexPath.row < MaxGoingTaskNumber)
        {
            var index = indexPath.row + 1
            imageview.image  = UIImage(named: "numbg\(index).png")
            labelnumber.hidden = true
            imageview.hidden = false
            labelname.hidden = false
        }
        else{
            if let taskbuilder = indexToTask(indexPath.row) {
                 imageview.hidden = true
                 labelnumber.hidden = false
                 labelname.hidden = false
                
                 var number = indexPath.row + 1
                 labelnumber.text = "\(number)"
         }
            else{
                
                labelname.text = ""
                
                imageview.hidden = true
                labelname.hidden = false
                labelnumber.hidden = true
            }
        }
        
        if let taskbuilder = indexToTask(indexPath.row) {
            labelname.text = taskbuilder.name
            checkbtn.hidden = false
            if(Globals.shared.isMyTaskNotFinished(taskbuilder)){
                
                labelname.textColor = UIColor.blackColor()
                checkbtn.selected = false
            
                if(taskbuilder.status == PkgTaskInfo.EnTaskStatus.TsDeny){
                    labelname.textColor = UIColor.redColor()
                }
            }
            else{
                labelname.textColor = UIColor.grayColor()
                checkbtn.selected = true
            }
        }
        else{
            labelname.text = ""
            checkbtn.hidden = true
        }
        var curdate = NSDate().formatted("YYYY-MM-dd")
        if let td = taskDatePicker{
            curdate = td.curDate.formatted("YYYY-MM-dd")
        }
        var todaydate = NSDate().formatted("YYYY-MM-dd")
        if( todaydate > curdate){
            checkbtn.hidden = true
        }
       
        
        cell = celltask as? UITableViewCell
        return cell!

    }
    
    private func indexToTask(index:Int) -> PkgTaskInfoBuilder?{
        var taskinfo:PkgTaskInfoBuilder?
        if(index < MaxGoingTaskNumber){
            if(self.task6Array.count > index){
                taskinfo = self.task6Array[index]
            }
        }
        else{
            if(self.task6Array.count > index){
                taskinfo = self.task6Array[index]
            }
            else{
                var going = self.task6Array.count > MaxGoingTaskNumber ? self.task6Array.count:MaxGoingTaskNumber
                var index2 = index - going
                if(self.taskFinishedArray.count > index2){
                    taskinfo = self.taskFinishedArray[index2]
                }
            }
        }
        return taskinfo
        
    }

    
    
    @IBAction func onCheckButtonClicked(sender: AnyObject) {
        let index = sender.layer.valueForKey("taskindex") as Int
        if let taskinfo =  indexToTask(index){
            var msgReq = PkgTaskOperationReq.builder()
            msgReq.taskoperation = PkgTaskOperationReq.EnTaskOperation.ToUpdateStatus.rawValue
            msgReq.taskid = taskinfo.id
            if(taskinfo.status == PkgTaskInfo.EnTaskStatus.TsFinished){
                if taskinfo.coworkid > 0 && taskinfo.accepteduserid == Int32(Globals.shared.userid){
                    msgReq.updatestatus = PkgTaskInfo.EnTaskStatus.TsGoing.rawValue
                }
                else{
                    msgReq.updatestatus = PkgTaskInfo.EnTaskStatus.TsNew.rawValue
                }
            }
            else{
                msgReq.updatestatus = PkgTaskInfo.EnTaskStatus.TsFinished.rawValue
            }
            var msgReply = PkgTaskOperationReply.builder()
            sendProtobufMsg(msgReq,msgReply,self.view,{
                (isOK:Bool,err:String?) ->Void in
                var bError = false
                var errString:String = ""
                
                if isOK{
                    if(msgReply.issuccess){
                        
                        GlobalMsgReqUtil.shared.sendNotifyReq(EnUpdatedFlag.UfMytaskfinishednumbers.rawValue|EnUpdatedFlag.UfMytask.rawValue)
                        
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
            })
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( section == 0){
            if(isExpand){
                var going = self.task6Array.count <= MaxGoingTaskNumber ? MaxGoingTaskNumber:self.task6Array.count
                return going + self.taskFinishedArray.count
            }
            return MaxGoingTaskNumber
        }
        return 0
     }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if let taskbuilder = indexToTask(indexPath.row) {
        
            self.performSegueWithIdentifier("todayTaskViewTaskSegue", sender: indexPath.row)
        }

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
       
            if segue.identifier == "todayTaskViewTaskSegue"{

                if let taskbuilder = indexToTask(sender as Int) {
                    var dvc:TaskDetailViewController = segue.destinationViewController as TaskDetailViewController
                    dvc.taskinfo.mergeFrom(taskbuilder.build())
                }
               // dvc.updateLabel()
            }
            else if segue.identifier == "todayTaskAddTaskSegue"{
                var dvc:TaskAddEditViewController = segue.destinationViewController as TaskAddEditViewController
                //新增;标志:选择任务,分配任务;已有任务数：task6Array.count
                var taskUI:Int = TaskUIFlag.SelTaskButton.rawValue | TaskUIFlag.AssginUser.rawValue
                var taskinfo:PkgTaskInfoBuilder = PkgTaskInfo.builder()
                taskinfo.id = 0
                taskinfo.taskdate = taskDatePicker!.curDate.formatted("YYYY-MM-dd")
                taskinfo.tasklevel = PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency
                dvc.setTask(TaskType.TaskAdd,taskUI:taskUI,taskinfoBuilder:taskinfo)
            }
        

    }

    func onClickAddTask(){
        self.performSegueWithIdentifier("todayTaskAddTaskSegue", sender: nil)
        
    }
    @IBAction func unwindToThisViewController(unwindSegue: UIStoryboardSegue){
        println("unwindToThisViewController")
    }
    func onTaskInfoChanged(){
        refreshData()
    }
   
}
