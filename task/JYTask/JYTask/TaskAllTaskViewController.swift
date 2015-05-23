//
//  TaskAllTaskViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-10.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class TaskAllTaskViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    let TAG_CELL_TEXTLABEL = 1
 
    @IBOutlet weak var btnAddnewtask: UIButton!
    @IBOutlet weak var btnViewallfinished: UIButton!
    @IBOutlet weak var tableview: UITableView!
    var taskImport0 = [Comm.PkgTaskInfo()]
    var taskImport1 = [Comm.PkgTaskInfo()]
    var taskImport2 = [Comm.PkgTaskInfo()]
    var taskImport3 = [Comm.PkgTaskInfo()]
    var taskSection = [String]()
    let TableHeaderSectionHeight:CGFloat = 20.0
    override func viewDidLoad() {
        super.viewDidLoad()
   
        TaskDetailInfo.getImportSectionArray(&taskSection)
        self.tableview.delegate = self
        self.tableview.dataSource = self
        tableview.sectionHeaderHeight = TableHeaderSectionHeight
        refreshData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)

        
        self.tableview.rowHeight = 40;
        self.tableview.sectionHeaderHeight = 30
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
        
        var taskMapCur = Dictionary<Int32,Comm.PkgTaskInfo>()
        var taskMapNew = GlobalMsgReqUtil.shared.taskAllNewTaskMap
        for taskbuilder in self.taskImport0{
            taskMapCur[taskbuilder.id] = taskbuilder
        }
        for taskbuilder in self.taskImport1{
            taskMapCur[taskbuilder.id] = taskbuilder
        }
        for taskbuilder in self.taskImport2{
            taskMapCur[taskbuilder.id] = taskbuilder
        }
        for taskbuilder in self.taskImport3{
            taskMapCur[taskbuilder.id] = taskbuilder
        }
        
        var taskAllArray = [Comm.PkgTaskInfo()]
        for (id,taskcur) in taskMapCur{
            if let tasknew = taskMapNew[id]{
                //判断taskbuildernew是否符合条件tasknew
                if(Globals.shared.isMyTask(tasknew)){
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
                if(Globals.shared.isMyTask(tasknew)){
                    taskAllArray.append(tasknew)
            }
        }
        
        //refresh
        self.taskImport0.removeAll(keepCapacity: false)
        self.taskImport1.removeAll(keepCapacity: false)
        self.taskImport2.removeAll(keepCapacity: false)
        self.taskImport3.removeAll(keepCapacity: false)
        
        for taskbuilder in taskAllArray{
        if(Globals.shared.isMyTaskNotFinished(taskbuilder)) {
            switch taskbuilder.tasklevel {
            case Comm.PkgTaskInfo.EnTaskLevel.TlImportanceArgency:
                self.taskImport0.append(taskbuilder)
            case Comm.PkgTaskInfo.EnTaskLevel.TlImportanceNotargency:
                self.taskImport1.append(taskbuilder)
            case Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceArgency:
                self.taskImport2.append(taskbuilder)
            case Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency:
                self.taskImport3.append(taskbuilder)
            default:
                break
            }
        }
        
        }
        sortTaskArray()
        self.tableview!.reloadData()
        
        
    }
    
    func sortTaskArray(){
        //排序
        sortTaskArrayWithSortFlag(&self.taskImport0,EnSortFlag.sortList)
        sortTaskArrayWithSortFlag(&self.taskImport1,EnSortFlag.sortList)
        sortTaskArrayWithSortFlag(&self.taskImport2,EnSortFlag.sortList)
        sortTaskArrayWithSortFlag(&self.taskImport3,EnSortFlag.sortList)
    }

    var gtaskImport0 = [Comm.PkgTaskInfo()]
    var gtaskImport1 = [Comm.PkgTaskInfo()]
    var gtaskImport2 = [Comm.PkgTaskInfo()]
    var gtaskImport3 = [Comm.PkgTaskInfo()]
    func refreshData(){
    
        UIActivityIndicatorView.showIndicatorInView(view!)
        dispatch_async(dispatch_get_main_queue(),{
            self.gtaskImport0.removeAll(keepCapacity: false)
            self.gtaskImport1.removeAll(keepCapacity: false)
            self.gtaskImport2.removeAll(keepCapacity: false)
            self.gtaskImport3.removeAll(keepCapacity: false)

            var msgReq = Comm.PkgTaskPageQueryReq.builder()
            msgReq.taskflag = Comm.PkgTaskPageQueryReq.EnTaskFlag.TfMytask
            msgReq.pageflag = Comm.PkgTaskPageQueryReq.EnPageFlag.PReturnall
            var msgReply = Comm.PkgTaskPageQueryReply.builder()
            
            GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
            
            for taskinfo in msgReply.taskinfolist{
                if(Globals.shared.isMyTaskNotFinished(taskinfo)) {
                    switch taskinfo.tasklevel {
                    case Comm.PkgTaskInfo.EnTaskLevel.TlImportanceArgency:
                        self.gtaskImport0.append(taskinfo)
                    case Comm.PkgTaskInfo.EnTaskLevel.TlImportanceNotargency:
                        self.gtaskImport1.append(taskinfo)
                    case Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceArgency:
                        self.gtaskImport2.append(taskinfo)
                    case Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency:
                        self.gtaskImport3.append(taskinfo)
                    default:
                        break
                    }
                }
            
            }
            
         //   dispatch_sync(dispatch_get_main_queue(),{
                self.taskImport0 = self.gtaskImport0
                self.taskImport1 = self.gtaskImport1
                self.taskImport2 = self.gtaskImport2
                self.taskImport3 = self.gtaskImport3
                self.sortTaskArray()
                self.tableview.reloadData()
                UIActivityIndicatorView.hideIndicatorInView(self.view!)
         //   });
        });
    }
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return taskSection.count
        //return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var celltask : AnyObject! = tableView.dequeueReusableCellWithIdentifier("celltask")

        
       // var cell : AnyObject! = tableView.dequeueReusableCellWithIdentifier("celltask")
        var label = celltask.viewWithTag(1001) as! UILabel
        var checkbtn = celltask.viewWithTag(1003) as! UIButton

        if let taskinfo = indexToTask(indexPath.section,indexrow:indexPath.row){
            checkbtn.addTarget(self, action: "onCheckButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            checkbtn.layer.setValue(indexPath.row, forKey: "taskindex")
            checkbtn.layer.setValue(indexPath.section, forKey: "tasksection")
            label.text = taskinfo.name
            checkbtn.hidden = false
        }
        else{
            checkbtn.hidden = true
            label.text = ""
        }
            
       
        return celltask as! UITableViewCell

    }
    
    
    @IBAction func onCheckButtonClicked(sender: AnyObject) {
        let index = sender.layer.valueForKey("taskindex") as! Int
        let tasksection = sender.layer.valueForKey("tasksection") as! Int
        if let taskinfo =  indexToTask(tasksection,indexrow:index){
            var msgReq = Comm.PkgTaskOperationReq.builder()
            msgReq.taskoperation = Comm.PkgTaskOperationReq.EnTaskOperation.ToUpdateStatus.rawValue
            msgReq.taskid = taskinfo.id
            if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                msgReq.updatestatus = Comm.PkgTaskInfo.EnTaskStatus.TsGoing.rawValue
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
    

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if( section < taskSection.count){
            return taskSection[section]
        }
        return ""
    }
    
    private func indexToTask(indexsection:Int,indexrow:Int) -> Comm.PkgTaskInfo?{
        var taskinfo:Comm.PkgTaskInfo?
        switch(indexsection){
        case 0:
            if(indexrow < taskImport0.count){
                taskinfo = taskImport0[indexrow]
            }
        case 1:
            if(indexrow < taskImport1.count){
                taskinfo = taskImport1[indexrow]
            }
        case 2:
            if(indexrow < taskImport2.count){
                taskinfo = taskImport2[indexrow]
            }
        case 3:
            if(indexrow < taskImport3.count){
                taskinfo = taskImport3[indexrow]
            }
        default:
            break
        }
        return taskinfo

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowcount = 0
        switch(section){
        case 0:
            rowcount = taskImport0.count
        case 1:
            rowcount = taskImport1.count
        case 2:
            rowcount = taskImport2.count
        case 3:
            rowcount = taskImport3.count
        default:
            break
        }
        return rowcount
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if let taskinfo = indexToTask(indexPath.section,indexrow: indexPath.row){
           
                var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
                var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("taskDetail") as! TaskDetailViewController
                dvc.taskinfo = taskinfo
                navigationController?.pushViewController(dvc,animated: true)
                
                //self.performSegueWithIdentifier("todayTaskViewTaskSegue", sender: indexPath.row)
           
        }
        
    }

    @IBAction func onClickViewallfinishedtask(sender: AnyObject) {
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("tasklist") as! TaskAllFinishedTaskViewController
        //  var dvc:TaskAllFinishedTaskViewController = segue.destinationViewController as TaskAllFinishedTaskViewController
        dvc.taskFlag =  TaskFlag.TaskAllFinished
        navigationController?.pushViewController(dvc,animated: true)

     //   navigationController?.pushViewController(dvc,animated: true)
       // self.performSegueWithIdentifier("toallfinishtaskSegue", sender: self)
    }
    
    @IBAction func onClickAddnewTask(sender: AnyObject) {
       // self.performSegueWithIdentifier("allTaskAddTaskSegue", sender: self)
        
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("taskAddEdit") as! TaskAddEditViewController
        var taskUI:Int = 0
        if (Globals.shared.companynumber > 1){
            taskUI = TaskUIFlag.AssginUser.rawValue
        }
        var taskinfobuilder:Comm.PkgTaskInfoBuilder = Comm.PkgTaskInfo.builder()
        taskinfobuilder.id = 0
        taskinfobuilder.tasklevel = Comm.PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency
        dvc.setTask(TaskType.TaskAdd,taskUI:taskUI,taskinfo:taskinfobuilder.build())
        navigationController?.pushViewController(dvc,animated: true)

    }   /**/
    // MARK: - Navigation
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 1.实例化标题视图。标题的自定义视图宽度最好不要写死
        var view = UIView()
        var headerLabel = UILabel()
        headerLabel.text = taskSection[section]
        headerLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(headerLabel)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[lab]-10-|", options: nil, metrics: nil, views:["lab":headerLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[lab]|",options:nil, metrics:nil, views:["lab":headerLabel]))
        view.backgroundColor = UIColor.colorWithHex("#EBEBEB")
        return view
    }
    
}
