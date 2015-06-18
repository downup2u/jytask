//
//  TaskCoworkTaskViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-10.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class TaskCoworkTaskViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var tasksendArray = [Comm.PkgTaskInfo()]
    var taskrecvArray = [Comm.PkgTaskInfo()]
    var taskSection = ["接受的任务","发送的任务"]
    
    var isSendNew = false
    var isRecvNew = false
    
    @IBOutlet weak var tableview:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.dataSource = self
        tableview.delegate = self

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
        if strtype == "allcoworktask" {
            refreshData()//如果使用refreshDataNew，没法知道已完成是否有更新，即没法显示红点
        }
    }
    
   
    
    
    var gtasksendArray = [Comm.PkgTaskInfo()]
    var gtaskrecvArray = [Comm.PkgTaskInfo()]
    
    var gisSendNew = false
    var gisRecvNew = false
    func refreshData(){
        
        UIActivityIndicatorView.showIndicatorInView(view!)
        dispatch_async(dispatch_get_main_queue(),{
            self.gtasksendArray.removeAll(keepCapacity: false)
            self.gtaskrecvArray.removeAll(keepCapacity: false)
            
            var msgReq = Comm.PkgTaskPageQueryReq.builder()
            msgReq.taskflag = Comm.PkgTaskPageQueryReq.EnTaskFlag.TfCoworktask
            msgReq.pageflag = Comm.PkgTaskPageQueryReq.EnPageFlag.PReturnall
            var msgReply = Comm.PkgTaskPageQueryReply.builder()
            GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
            
            self.gisSendNew = false
            self.gisRecvNew = false
            for taskinfo in msgReply.taskinfolist{
                
                if(Int(taskinfo.createuserid) == Globals.shared.userid){
                    if(taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                        self.gtasksendArray.append(taskinfo)
                    }
                    else{
                        if(taskinfo.isreaded == 0){
                            self.gisSendNew = true
                        }
                    }
                }
                else if(Int(taskinfo.accepteduserid) == Globals.shared.userid){
                    if(taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsFinished
                        && taskinfo.status != Comm.PkgTaskInfo.EnTaskStatus.TsDeny){
                            self.gtaskrecvArray.append(taskinfo)
                    }
                    else{
                        if(taskinfo.isreaded == 0){
                            self.gisRecvNew = true
                        }
                    }
                }
                else{
                    println("error:\(taskinfo)")
                }
            }

         //   dispatch_sync(dispatch_get_main_queue(),{
                self.tasksendArray = self.gtasksendArray
                self.taskrecvArray = self.gtaskrecvArray
                self.isSendNew = self.gisSendNew
                self.isRecvNew = self.gisRecvNew
                self.sortTaskArray()
                self.tableview.reloadData()
                UIActivityIndicatorView.hideIndicatorInView(self.view!)
         //   });
        });
    }
    func sortTaskArray(){
        //接受的任务做排序
        
        sortTaskArrayWithSortFlag(&self.taskrecvArray,EnSortFlag.sortList)
        //发送的任务做排序
        sortTaskArrayWithSortFlag(&self.tasksendArray,EnSortFlag.sortList)
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
    }
    private func indexToTask(indexPath: NSIndexPath) -> Comm.PkgTaskInfo?{
        var taskinfo:Comm.PkgTaskInfo?
        if(indexPath.section == 0){
            if(taskrecvArray.count > indexPath.row){
                taskinfo = taskrecvArray[indexPath.row]
            }
        }
        else{
            if(tasksendArray.count > indexPath.row){
                taskinfo = tasksendArray[indexPath.row]
            }
            
        }
        return taskinfo

    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        var celltask : AnyObject! = tableView.dequeueReusableCellWithIdentifier("celltask")
        var labeltaskname = celltask.viewWithTag(1001) as! UILabel
        var labeltaskstatus = celltask.viewWithTag(1002) as! UILabel
        var username = ""

        if let taskinfo = indexToTask(indexPath){
            if(taskinfo.isreaded == 0){
                labeltaskname.font = UIFont.boldSystemFontOfSize(17.0)
                labeltaskstatus.font = UIFont.boldSystemFontOfSize(14.0)
            }
            else{
                labeltaskname.font = UIFont.systemFontOfSize(17.0)
                labeltaskstatus.font = UIFont.systemFontOfSize(14.0)
            }
            if indexPath.section == 0{
                //接受任务
                username = taskinfo.createdrealname
            }
            else {
                username = taskinfo.acceptedrealname
            }
            labeltaskname.text = "\(taskinfo.name)(\(username))"
            switch(taskinfo.status){
                case Comm.PkgTaskInfo.EnTaskStatus.TsNew:
                    labeltaskstatus.text = "未接受"
                case Comm.PkgTaskInfo.EnTaskStatus.TsGoing:
                    labeltaskstatus.text = "已接受"
                case Comm.PkgTaskInfo.EnTaskStatus.TsDeny:
                    labeltaskstatus.text = "已拒绝"
                case Comm.PkgTaskInfo.EnTaskStatus.TsFinished:
                    labeltaskstatus.text = "已完成"
                default:
                    labeltaskstatus.text = ""
            }
        }
        
        
        var cell = celltask as? UITableViewCell
        return cell!
        
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return taskSection[section]
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if( section == 0){
            return taskrecvArray.count
        }
        return tasksendArray.count
    }
    
    

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        // 1.实例化标题视图。标题的自定义视图宽度最好不要写死
        var view = UIView()
        // 2.在标题视图中添加一个按钮
        var button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        //button.titleLabel?.text = "查看已完成"
        button.setTitle("查看已完成", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15.0)
      //  button.frame = CGRectMake(tableView.bounds.width/2, 0, tableView.bounds.width/2, 40)
        // 添加标题按钮的监听方法
        button.tag = section
        button.addTarget(self, action: Selector("clickHeader:"), forControlEvents: UIControlEvents.TouchUpInside)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var headerLabel = UILabel()
        
        var isnew = false
        if(section == 0){
            isnew = self.isRecvNew
        }
        else{
            isnew = self.isSendNew
        }
        println("section=\(section),isnew:\(isnew)")
        
        headerLabel.text = taskSection[section]

        
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        headerLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        view.addSubview(headerLabel)
        view.addSubview(button)
        
       // isnew = section == 0 //for test


        if(isnew){
            var imageNormal = UIImage(named:"newdot")!
            button.setImage(imageNormal, forState: UIControlState.Normal)
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[lab]-[btn(160)]-1-|", options: nil, metrics: nil, views:["lab":headerLabel, "btn":button]))
        }
        else{
           view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[lab]-[btn(160)]-25-|", options: nil, metrics: nil, views:["lab":headerLabel, "btn":button]))
        }
        button.setTitleColor(UIColor.colorWithHex("#1E90FF"), forState: UIControlState.Normal)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[lab]|",options:nil, metrics:nil, views:["lab":headerLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[btn]|",options:nil, metrics:nil, views:["btn":button]))

        view.backgroundColor = UIColor.colorWithHex("#EBEBEB")
        
        if(isnew){
            addButtonNewDot(button)
        }
        return view
    }

    
    override func willMoveToParentViewController(parent:UIViewController?) {
        println("TaskCowork willMoveToParentViewController...\(self.view.frame),table:\(self.tableview.frame)")
    }
    
    override func didMoveToParentViewController(parent:UIViewController?) {
        println("TaskCowork didMoveToParentViewController...\(self.view.frame),table:\(self.tableview.frame)")
    }
    override func viewWillLayoutSubviews(){
        
    }
    
//    override func viewDidLayoutSubviews(){
//        self.tableview.frame = self.view.bounds
//     }

    func clickHeader(button:UIButton) {
       // println("点击了第\(button.tag)组")
       // self.performSegueWithIdentifier("tofinishedtasksegue", sender: button.tag)
        var section = button.tag
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("tasklist") as! TaskAllFinishedTaskViewController
      //  var dvc:TaskAllFinishedTaskViewController = segue.destinationViewController as TaskAllFinishedTaskViewController
        dvc.taskFlag = (section == 0) ? TaskFlag.CoworkRecvFinished : TaskFlag.CoworkSendFinished
        navigationController?.pushViewController(dvc,animated: true)
    }
    // MARK: - Navigation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("taskDetail") as! TaskDetailViewController
   //     var indexPath = sender as NSIndexPath
        var selsection = indexPath.section
        var selrow = indexPath.row
        switch(selsection){
        case 0:
            dvc.taskinfo = taskrecvArray[selrow]
        case 1:
            dvc.taskinfo = tasksendArray[selrow]
        default:
            println("err")
        }

        navigationController?.pushViewController(dvc,animated: true)
        // self.performSegueWithIdentifier("coworkTaskViewTaskSegue", sender: indexPath)
    }


}
