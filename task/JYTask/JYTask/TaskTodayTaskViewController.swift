//
//  TaskTodayTaskViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-10.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit
//import Snappy

class TaskTodayTaskViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
    let MaxGoingTaskNumber = 6
    var taskNotFinishedArray = [Comm.PkgTaskInfo()]
    var taskFinishedArray = [Comm.PkgTaskInfo()]
    var isExpand = true
    let TableHeaderSectionHeight:CGFloat = 40.0
    @IBOutlet weak var tableview:UITableView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableview.dataSource = self
        tableview.delegate = self
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight
        self.view.autoresizesSubviews = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)
      
        popDatePicker = PopDatePicker(sourceView: self.view)
        self.setMyCurDate(self.curDate)
        
        tableview.sectionHeaderHeight = TableHeaderSectionHeight
        self.tableview.rowHeight = 44;
        
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
        var date = self.curDate.formatted("yyyy-MM-dd")
        
        var taskMapCur = Dictionary<Int32,Comm.PkgTaskInfo>()
        var taskMapNew = GlobalMsgReqUtil.shared.taskAllNewTaskMap
        for taskinfo in self.taskNotFinishedArray{
            taskMapCur[taskinfo.id] = taskinfo
        }
        for taskinfo in self.taskFinishedArray{
            taskMapCur[taskinfo.id] = taskinfo
        }
        
        var taskAllArray = [Comm.PkgTaskInfo()]
        for (id,taskcur) in taskMapCur{
            if let tasknew = taskMapNew[id]{
                //判断taskbuildernew是否符合条件
                if(Globals.shared.isMyTask(tasknew) && date == tasknew.taskdate){
                    taskAllArray.append(tasknew)
                }
                //remove it
                taskMapNew.removeValueForKey(id)
            }
            else{
                taskAllArray.append(taskcur)
            }
        }
        for (id,tasknew) in taskMapNew{
            //判断taskbuildernew是否符合条件
            if(Globals.shared.isMyTask(tasknew) && date == tasknew.taskdate){
                taskAllArray.append(tasknew)
            }
        }
        
        taskNotFinishedArray.removeAll(keepCapacity: true)
        taskFinishedArray.removeAll(keepCapacity: true)
        
        
        for taskall in taskAllArray{
            if(Globals.shared.isMyTaskNotFinished(taskall)){
                self.taskNotFinishedArray.append(taskall)
            }
            else {
                if( taskall.status != Comm.PkgTaskInfo.EnTaskStatus.TsDeleted){
                    self.taskFinishedArray.append(taskall)
                }
            }
            
        }
        sortTaskArray()
        tableview.reloadData()
    }

    var popDatePicker : PopDatePicker?

    func onClickSelDate(){
        var initDate = self.curDate
        popDatePicker!.pick(self, initDate:initDate, dataChanged: {
            (newDate : NSDate, sourceView : UIView) -> () in
            
            self.setMyCurDate(newDate)
            self.refreshData()
        })
    }
    

  
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnAddTask: UIButton!
    
    @IBOutlet weak var btnPickDate: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var curDate = NSDate()
    @IBAction func onClickPrevDate(sender: AnyObject) {
        curDate = curDate.add(days:-1)
        var dateString = self.curDate.formatted("yyyy-MM-dd")
        println("curdate:\(dateString)")
        btnPickDate.setTitle(dateString, forState: UIControlState.Normal)
        self.datePickerChanged(dateString)
    }
    @IBAction func onClickNextDate(sender: AnyObject) {
        
        curDate = curDate.add(days:1)
        var dateString = self.curDate.formatted("yyyy-MM-dd")
        println("curdate:\(dateString)")
        btnPickDate.setTitle(dateString, forState: UIControlState.Normal)
        self.datePickerChanged(dateString)
    }
    @IBAction func onClickPickDate(sender: AnyObject) {
        
        self.onClickSelDate()
    }
    
    @IBAction func onClickAddTask(sender: AnyObject) {
        btnAddTask.enabled = false
        self.onClickAddTask()
        btnAddTask.enabled = true
    }
    
    func setAddTaskBtnHidden(hidden:Bool){
        btnAddTask.hidden = hidden
    }
    func setMyCurDate(date:NSDate){
        curDate = date
        var dateString = self.curDate.formatted("yyyy-MM-dd")
        btnPickDate.setTitle(dateString, forState: UIControlState.Normal)
        
        var todaydate = NSDate().formatted("yyyy-MM-dd")
        println("todaydate:\(todaydate),dateString:\(dateString)")
        if todaydate > dateString {//选择今天以前的日期
            btnAddTask.hidden = true
        }
        else {
            btnAddTask.hidden = false
        }
        
        self.datePickerChanged(dateString)
    }

    
    
    

    func datePickerChanged(date : String){
        var todaydate = NSDate().formatted("yyyy-MM-dd")
        self.setAddTaskBtnHidden(todaydate > date)
      
        refreshData()
    }
    
    
    var gtaskNotFinishedArray = [Comm.PkgTaskInfo()]
    var gtaskFinishedArray = [Comm.PkgTaskInfo()]
    private func refreshData(){
        UIActivityIndicatorView.showIndicatorInView(view!)
        dispatch_async(dispatch_get_main_queue(),{
            self.gtaskNotFinishedArray.removeAll(keepCapacity: false)
            self.gtaskFinishedArray.removeAll(keepCapacity: false)

            var date = self.curDate.formatted("yyyy-MM-dd")
            var msgReq = Comm.PkgTaskPageQueryReq.builder()
            msgReq.taskflag = Comm.PkgTaskPageQueryReq.EnTaskFlag.TfMytask
            msgReq.enconditon = Comm.PkgTaskPageQueryReq.EnTaskQueryCondition.TqcDatestart.rawValue |
                Comm.PkgTaskPageQueryReq.EnTaskQueryCondition.TqcDateend.rawValue
            var condition = Comm.PkgTaskPageQueryReq.PkgTaskQueryCondition.builder()
            condition.taskdatestart = date
            condition.taskdateend = date
            msgReq.pkgtaskquerycondition = condition.build()
            msgReq.pageflag = Comm.PkgTaskPageQueryReq.EnPageFlag.PReturnall
            var msgReply = Comm.PkgTaskPageQueryReply.builder()
            GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
            
            for taskinfo in msgReply.taskinfolist{
                if(Globals.shared.isMyTaskNotFinished(taskinfo)){
                    self.gtaskNotFinishedArray.append(taskinfo)
                }
                else {
                    if( taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsDeleted){
                        self.gtaskFinishedArray.append(taskinfo)
                    }
                }

            }
           // dispatch_sync(dispatch_get_main_queue(),{
                self.taskNotFinishedArray = self.gtaskNotFinishedArray
                self.taskFinishedArray = self.gtaskFinishedArray
                self.sortTaskArray()
                self.tableview.reloadData()
                UIActivityIndicatorView.hideIndicatorInView(self.view!)
           // });
        });
   
    }
    
    func sortTaskArray(){
  
        sortTaskArrayWithSortFlag(&self.taskNotFinishedArray,EnSortFlag.sortNotFinished)
        sortTaskArrayWithSortFlag(&self.taskFinishedArray,EnSortFlag.sortFinished)

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
        var   labelnumber = celltask.viewWithTag(1000) as! UILabel
        var   imageview = celltask.viewWithTag(1001) as! UIImageView
        var   labelname = celltask.viewWithTag(1002) as! UILabel
        var   checkbtn = celltask.viewWithTag(1003) as! UIButton
        checkbtn.addTarget(self, action: "onCheckButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        checkbtn.layer.setValue(indexPath.row, forKey: "taskindex")
        
        labelnumber.hidden = true
        imageview.hidden = true
        labelname.hidden = true
        checkbtn.hidden = true
        
        if(indexPath.row < MaxGoingTaskNumber)
        {
            var index = indexPath.row + 1
            imageview.image  = UIImage(named: "numbg\(index).png")
           
            imageview.hidden = false
            labelname.hidden = false
        }
        else{
            if let taskbuilder = indexToTask(indexPath.row) {
       
                 labelnumber.hidden = false
                 labelname.hidden = false
                
                 var number = indexPath.row + 1
                 labelnumber.text = "\(number)"
            }
            else{
                labelname.text = ""
                labelname.hidden = false
            }
        }
        
        if let taskinfo = indexToTask(indexPath.row) {
            
            if(Globals.shared.isCoworkTask(taskinfo)){
                var username = ""
                if (Int(taskinfo.accepteduserid) == Globals.shared.userid){
                //接受任务
                    username = taskinfo.createdrealname
                }
                else {
                    username = taskinfo.acceptedrealname
                }
                labelname.text = "\(taskinfo.name)(\(username))"
            }
            else{
                labelname.text = taskinfo.name
            }
            
            
            checkbtn.hidden = false
            if(Globals.shared.isMyTaskNotFinished(taskinfo)){
                
                if(taskinfo.coworkid > 0
                    && Int(taskinfo.createuserid) == Globals.shared.userid
                    && taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsGoing){
                    //自己发送给别人的任务,别人已接受
                        checkbtn.hidden = true
                }
                labelname.textColor = UIColor.blackColor()
                checkbtn.selected = false
            
                if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsDeny){
                    labelname.textColor = UIColor.redColor()
                }
            }
            else{
                labelnumber.hidden = true
                labelname.textColor = UIColor.grayColor()
                checkbtn.selected = true
            }
        }
        else{
            labelname.text = ""
        }
        
        var curdate = self.curDate.formatted("yyyy-MM-dd")
        var todaydate = NSDate().formatted("yyyy-MM-dd")
        if( todaydate > curdate){
            checkbtn.hidden = true
        }
        cell = celltask as? UITableViewCell
        return cell!

    }
    
    private func indexToTask(index:Int) -> Comm.PkgTaskInfo?{
        var taskinfo:Comm.PkgTaskInfo?
        if(index < MaxGoingTaskNumber){
            if(self.taskNotFinishedArray.count > index){
                taskinfo = self.taskNotFinishedArray[index]
            }
        }
        else{
            if(self.taskNotFinishedArray.count > index){
                taskinfo = self.taskNotFinishedArray[index]
            }
            else{
                var going = self.taskNotFinishedArray.count > MaxGoingTaskNumber ? self.taskNotFinishedArray.count:MaxGoingTaskNumber
                var index2 = index - going
                if(self.taskFinishedArray.count > index2){
                    taskinfo = self.taskFinishedArray[index2]
                }
            }
        }
        return taskinfo
        
    }

    
    
    @IBAction func onCheckButtonClicked(sender: AnyObject) {
        let index = sender.layer.valueForKey("taskindex") as! Int
        if let taskinfo =  indexToTask(index){
            var msgReq = Comm.PkgTaskOperationReq.builder()
            msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToUpdateStatus.rawValue
            msgReq.taskid = taskinfo.id
            if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                if taskinfo.coworkid > 0 && taskinfo.accepteduserid == Int32(Globals.shared.userid){
                    msgReq.updatestatus = Comm.PkgTaskInfo.EnTaskStatus.TsGoing.rawValue
                }
                else{
                    msgReq.updatestatus = Comm.PkgTaskInfo.EnTaskStatus.TsNew.rawValue
                }
            }
            else{
                msgReq.updatestatus = Comm.PkgTaskInfo.EnTaskStatus.TsFinished.rawValue
            }
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
                        
                        GlobalMsgReqUtil.shared.sendNotifyReq(Comm.EnUpdatedFlag.UfMytaskfinishednumbers.rawValue|Comm.EnUpdatedFlag.UfMytask.rawValue)
                        
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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( section == 0){
            if(isExpand){
                var going = self.taskNotFinishedArray.count <= MaxGoingTaskNumber ? MaxGoingTaskNumber:self.taskNotFinishedArray.count
                return going + self.taskFinishedArray.count
            }
            return MaxGoingTaskNumber
        }
        return 0
     }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if let taskinfo = indexToTask(indexPath.row) {
            var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
            var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("taskDetail") as! TaskDetailViewController
            dvc.taskinfo = taskinfo
            navigationController?.pushViewController(dvc,animated: true)

            //self.performSegueWithIdentifier("todayTaskViewTaskSegue", sender: indexPath.row)
        }

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//       
//            if segue.identifier == "todayTaskViewTaskSegue"{
//
//                if let taskinfo = indexToTask(sender as Int) {
//                    var dvc:TaskDetailViewController = segue.destinationViewController as TaskDetailViewController
//                    dvc.taskinfo = taskinfo
//                }
//               // dvc.updateLabel()
//            }
//            else if segue.identifier == "todayTaskAddTaskSegue"{
//                var dvc:TaskAddEditViewController = segue.destinationViewController as TaskAddEditViewController
//               
//                var taskUI:Int = TaskUIFlag.SelTaskButton.rawValue | TaskUIFlag.AssginUser.rawValue
//                var taskinfobuilder:PkgTaskInfoBuilder = PkgTaskInfo.builder()
//                taskinfobuilder.id = 0
//                taskinfobuilder.taskdate = self.curDate.formatted("yyyy-MM-dd")
//                taskinfobuilder.tasklevel = PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency
//                dvc.setTask(TaskType.TaskAdd,taskUI:taskUI,taskinfo:taskinfobuilder.build())
//               
//            }
//        
//
//    }

    func onClickAddTask(){
        
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("taskAddEdit") as! TaskAddEditViewController
        var taskUI:Int = TaskUIFlag.SelTaskButton.rawValue 
        if (Globals.shared.companynumber > 1){
            taskUI = taskUI | TaskUIFlag.AssginUser.rawValue
        }
        var taskinfobuilder:Comm.PkgTaskInfoBuilder = Comm.PkgTaskInfo.builder()
        taskinfobuilder.id = 0
        taskinfobuilder.taskdate = self.curDate.formatted("yyyy-MM-dd")
        taskinfobuilder.tasklevel = Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency
        dvc.setTask(TaskType.TaskAdd,taskUI:taskUI,taskinfo:taskinfobuilder.build())
        navigationController?.pushViewController(dvc,animated: true)
     //     self.performSegueWithIdentifier("todayTaskAddTaskSegue", sender: self)
    }
    @IBAction func unwindToThisViewController(unwindSegue: UIStoryboardSegue){
        println("unwindToThisViewController")
    }
    func onTaskInfoChanged(){
        refreshData()
    }
}
