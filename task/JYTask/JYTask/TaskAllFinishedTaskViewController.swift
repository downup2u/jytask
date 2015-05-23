//
//  TaskAllFinishedTaskViewController.swift
//  JYTask
//
//  Created by wxqdev on 14-10-23.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

public enum TaskFlag{
    case TaskAllFinished
    case TaskNotFinished
    case CoworkSendFinished
    case CoworkRecvFinished
    case ChooseNotFinishedTask
}

public enum LineStyle{
    case LineStyleShowUsername
    case LineStyleShowCheckBtn
    case LineStyleNormal
}

class TaskAllFinishedTaskViewController: UIViewController,UITableViewDataSource,UITableViewDelegate ,UISearchBarDelegate{
 
    
    var taskImport0 = [Comm.PkgTaskInfo()]
    var taskImport1 = [Comm.PkgTaskInfo()]
    var taskImport2 = [Comm.PkgTaskInfo()]
    var taskImport3 = [Comm.PkgTaskInfo()]
    var taskArray = [Comm.PkgTaskInfo()]
    
    var taskSection = [String]()
    
    var delegate:TaskChooseDelegate?

    var taskFlag = TaskFlag.TaskAllFinished
    
    //table style
    private func isShowSection4()->Bool{
        if (taskFlag == TaskFlag.CoworkSendFinished
            || taskFlag == TaskFlag.CoworkRecvFinished){
                return false
        }
        return true
    }
    private func getLineStyle()->LineStyle{
         if (taskFlag == TaskFlag.CoworkSendFinished
            || taskFlag == TaskFlag.CoworkRecvFinished){
                return LineStyle.LineStyleShowUsername
        }
         else if(taskFlag == TaskFlag.TaskAllFinished
            || taskFlag == TaskFlag.TaskNotFinished){
            return LineStyle.LineStyleShowCheckBtn
        }
        return LineStyle.LineStyleNormal
    }
    private func isClickToDetail()->Bool{
        if(taskFlag == TaskFlag.ChooseNotFinishedTask){
            return false
        }
        return true
    }
    private func isTaskTypeFinished()->Bool{
        if(taskFlag == TaskFlag.ChooseNotFinishedTask || taskFlag == TaskFlag.TaskNotFinished){
            return false
        }
        return true
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
//    override func viewDidLayoutSubviews(){
//       
//        self.tableview.frame = self.view.bounds
//        self.tableview.frame.origin.y = searchBar.frame.origin.y + searchBar.height
//        tableview.height -= self.topLayoutGuide.length
//        tableview.height -= self.bottomLayoutGuide.length
//        tableview.height -= searchBar.height
//
//        
//    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        self.tableview.rowHeight = 40;
        self.tableview.sectionHeaderHeight = 30

        TaskDetailInfo.getImportSectionArray(&taskSection)
        
        var title = ""
        switch (taskFlag){
        case TaskFlag.TaskAllFinished:
            title = "已完成任务"
        case TaskFlag.TaskNotFinished:
            title = "未完成任务"
        case TaskFlag.CoworkSendFinished:
            title = "已发送协作任务(已完成)"
        case TaskFlag.CoworkRecvFinished:
            title = "已接受协作任务(已完成)"
        case TaskFlag.ChooseNotFinishedTask:
            title = "选择任务"
        default:
            break
        }
        self.navigationItem.title = title
        
        if(isClickToDetail()){
            self.navigationItem.rightBarButtonItem = nil
        }

        refreshData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)
        self.searchBar.delegate = self
        self.searchBar.placeholder = "请输入要搜索的任务关键字"
        var navigationBarViewRect:CGRect = CGRectMake(0.0,0.0,0.0,0.0)
        keyboard = KeyboardManager(controller: self,navRect:navigationBarViewRect)
    }
    
    
    var keyboard:KeyboardManager!
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        keyboard.enableKeyboardManger()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        keyboard.disableKeyboardManager()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        keyboard.endEditing()
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func onDataChanged(notification: NSNotification){
        var strtype: String = notification.object as! String
        if strtype == "allmytask" {
            refreshData()
        }
    }
    
    func refreshData(){
       sendReq("")
    }
    

    

    @IBAction func onClickOK(sender: AnyObject) {
        var indexPath:NSIndexPath? = self.tableview.indexPathForSelectedRow()
        if( indexPath != nil){
            if let taskinfo = indexToTask(indexPath!.section,indexrow: indexPath!.row){
                self.delegate?.onTaskChoosed(taskinfo)
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    //for
    var gtaskImport0 = [Comm.PkgTaskInfo()]
    var gtaskImport1 = [Comm.PkgTaskInfo()]
    var gtaskImport2 = [Comm.PkgTaskInfo()]
    var gtaskImport3 = [Comm.PkgTaskInfo()]
    var gtaskArray = [Comm.PkgTaskInfo()]
    var gsearchText = ""
    
    func sendReq(var searchText:String){

        gsearchText = searchText

        UIActivityIndicatorView.showIndicatorInView(view!)
        dispatch_async(dispatch_get_main_queue(),{
            self.gtaskImport0.removeAll(keepCapacity: false)
            self.gtaskImport1.removeAll(keepCapacity: false)
            self.gtaskImport2.removeAll(keepCapacity: false)
            self.gtaskImport3.removeAll(keepCapacity: false)
            self.gtaskArray.removeAll(keepCapacity: false)
            var msgReq = Comm.PkgTaskPageQueryReq.builder()
            msgReq.enconditon = Comm.PkgTaskPageQueryReq.EnTaskQueryCondition.TqcKeyforname.rawValue |
                Comm.PkgTaskPageQueryReq.EnTaskQueryCondition.TqcKeyforcontent.rawValue
            var condition = Comm.PkgTaskPageQueryReq.PkgTaskQueryCondition.builder()
            condition.keyforname = self.gsearchText
            condition.keyforcontent = self.gsearchText
            var msgReply = Comm.PkgTaskPageQueryReply.builder()
            if (self.getLineStyle() == LineStyle.LineStyleShowUsername){
                //for coworktask
                msgReq.pkgtaskquerycondition = condition.build()
                msgReq.taskflag = Comm.PkgTaskPageQueryReq.EnTaskFlag.TfCoworktask
                msgReq.pageflag = Comm.PkgTaskPageQueryReq.EnPageFlag.PReturnall
                
                GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
                
                for taskinfo in msgReply.taskinfolist{
                    
                    
                    if(Int(taskinfo.createuserid) == Globals.shared.userid){
                        if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                            if(self.taskFlag == TaskFlag.CoworkSendFinished){
                                self.gtaskArray.append(taskinfo)
                            }
                        }
                    }
                    else if(Int(taskinfo.accepteduserid) == Globals.shared.userid){
                        if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished
                            || taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsDeny){
                                if(self.taskFlag == TaskFlag.CoworkRecvFinished){
                                    self.gtaskArray.append(taskinfo)
                                }
                                
                        }
                    }
                }
                
            }
            else{
                
                msgReq.taskflag = Comm.PkgTaskPageQueryReq.EnTaskFlag.TfMytask
                msgReq.pageflag = Comm.PkgTaskPageQueryReq.EnPageFlag.PReturnall
                msgReq.pkgtaskquerycondition = condition.build()
                
                GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
                
                for taskinfo in msgReply.taskinfolist{
                    var isSkip = false
                    if(Globals.shared.isMyTaskNotFinished(taskinfo)){
                        //not finished
                        if(self.taskFlag == TaskFlag.TaskAllFinished){
                            isSkip = true
                        }
                        else if(self.taskFlag == TaskFlag.ChooseNotFinishedTask){
                            //filter today
                            if(taskinfo.taskdate == NSDate().formatted("yyyy-MM-dd")){
                                isSkip = true
                            }
                        }
                    }
                    else{
                        //finished
                        if(self.taskFlag == TaskFlag.TaskNotFinished
                            || self.taskFlag == TaskFlag.ChooseNotFinishedTask){
                                isSkip = true
                        }
                    }
                    
                    
                    
                    if(!isSkip){
                        if(!self.isShowSection4()){
                            self.gtaskArray.append(taskinfo)
                        }
                        else{
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
                }
            }
            

           // dispatch_sync(dispatch_get_main_queue(),{
                self.taskArray = self.gtaskArray
                self.taskImport0 = self.gtaskArray
                self.taskImport1 = self.gtaskImport1
                self.taskImport2 = self.gtaskImport2
                self.taskImport3 = self.gtaskImport3
                self.sortTaskArray()
                self.tableview.reloadData()
                UIActivityIndicatorView.hideIndicatorInView(self.view!)
          //  });
        });
        
        

    }
    func sortTaskArray(){
        if(!isShowSection4()){
            sortTaskArrayWithSortFlag(&self.taskArray,EnSortFlag.sortList);
        }
        else{
            sortTaskArrayWithSortFlag(&self.taskImport0,EnSortFlag.sortList);
            sortTaskArrayWithSortFlag(&self.taskImport1,EnSortFlag.sortList);
            sortTaskArrayWithSortFlag(&self.taskImport2,EnSortFlag.sortList);
            sortTaskArrayWithSortFlag(&self.taskImport3,EnSortFlag.sortList);
            
        }
    }
    @IBOutlet weak var tableview: UITableView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickReturn(sender: AnyObject) {
      navigationController?.popViewControllerAnimated(true)
    }



    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(isShowSection4()){
            return taskSection.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var celltask : AnyObject! = tableView.dequeueReusableCellWithIdentifier("celltask")
        var label = celltask.viewWithTag(1001) as! UILabel
        var labelstatus = celltask.viewWithTag(1002) as! UILabel
        var checkbtn = celltask.viewWithTag(1003) as! UIButton
        labelstatus.hidden = true
        checkbtn.hidden = true
        label.hidden = true
        if let taskinfo = indexToTask(indexPath.section,indexrow: indexPath.row){
            label.hidden = false
            
    
            if (getLineStyle() == LineStyle.LineStyleShowUsername){
                if(taskinfo.status == Comm.PkgTaskInfo.EnTaskStatus.TsFinished){
                    checkbtn.addTarget(self, action: "onCheckButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
                    checkbtn.layer.setValue(indexPath.row, forKey: "taskindex")
                    checkbtn.layer.setValue(indexPath.section, forKey: "tasksection")
                    checkbtn.hidden = false
                    checkbtn.selected = true
                }
                else{
                    labelstatus.text = "拒绝"
                    labelstatus.hidden = false
                }
                var username = ""
                if taskFlag == TaskFlag.CoworkRecvFinished{
                    username = taskinfo.createdrealname
                }
                else {
                    username = taskinfo.acceptedrealname
                }
                label.text = "\(taskinfo.name)(\(username))"
                if(taskinfo.isreaded == 0){
                    label.font = UIFont.boldSystemFontOfSize(17.0)
                }
                else{
                    label.font = UIFont.systemFontOfSize(17.0)
                }
            }
            else if (getLineStyle() == LineStyle.LineStyleShowCheckBtn){
                checkbtn.addTarget(self, action: "onCheckButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
                checkbtn.layer.setValue(indexPath.row, forKey: "taskindex")
                checkbtn.layer.setValue(indexPath.section, forKey: "tasksection")
                checkbtn.hidden = false
                label.text = "\(taskinfo.name)"
                if(isTaskTypeFinished()){
                    checkbtn.selected = true
                }
                else{
                    checkbtn.selected = false
                }

            }
            else{
                label.text = "\(taskinfo.name)"
            }
        }

        return celltask as! UITableViewCell
        
        
    }
    
     @IBAction func onCheckButtonClicked(sender: AnyObject) {
        let section = sender.layer.valueForKey("tasksection") as! Int
        let index = sender.layer.valueForKey("taskindex") as! Int
        if let taskinfo = indexToTask(section,indexrow: index){
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
    

    
    func indexToTask(indexsection:Int,indexrow:Int) -> Comm.PkgTaskInfo?{
        var taskinfo:Comm.PkgTaskInfo?
        if(isShowSection4()){
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
        }
        else{
            if(taskArray.count > indexrow){
                taskinfo = taskArray[indexrow]
            }
        }
        return taskinfo
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        var rowcount = taskArray.count
        if(isShowSection4()){
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
                rowcount = 0
                break
            }
        }
        return rowcount
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        if(isShowSection4()){
            if( section < taskSection.count){
                return taskSection[section]
            }
        }
        return ""
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(isClickToDetail()){
            //self.performSegueWithIdentifier("totaskdetailSegue", sender: indexPath)
            if let taskinfo = indexToTask(indexPath.section,indexrow:indexPath.row){
                var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
                var dvc = storyBoardTask.instantiateViewControllerWithIdentifier("taskDetail") as!TaskDetailViewController
               
                var selsection = indexPath.section
                var selrow = indexPath.row
                dvc.taskinfo = taskinfo
                navigationController?.pushViewController(dvc,animated: true)
          }
        }
 
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "totaskdetailSegue"{
//            var indexPath = sender as NSIndexPath
//            if let taskinfo = indexToTask(indexPath.section,indexrow:indexPath.row){
//                var dvc:TaskDetailViewController = segue.destinationViewController as TaskDetailViewController
//                
//                var selsection = indexPath.section
//                var selrow = indexPath.row
//                dvc.taskinfo = taskinfo
//            }
//          
//        }
//
//    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchtext = searchBar.text
        keyboard.endEditing()
     //   doSearch(searchBar,searchtext:searchtext)
    }
    

    func searchBar(searchBar: UISearchBar,textDidChange searchText: String){
        
        doSearch(searchBar,searchtext:searchText)
    }

    
    func doSearch(searchBar: UISearchBar,var searchtext :String){
        //searchBar.setShowsCancelButton(true, animated: true)
        sendReq(searchtext)

    }

}
