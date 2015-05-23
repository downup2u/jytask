//
//  TaskChooseTaskViewController.swift
//  JYTask
//
//  Created by wxqdev on 14-10-22.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

class TaskChooseTaskViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    var delegate:TaskChooseDelegate?
    var taskImport0 = [PkgTaskInfoBuilder]()
    var taskImport1 = [PkgTaskInfoBuilder]()
    var taskImport2 = [PkgTaskInfoBuilder]()
    var taskImport3 = [PkgTaskInfoBuilder]()
    var taskSection = ["重要紧急","重要不紧急","不重要紧急","不重要不紧急"]
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLayoutSubviews(){
        
        self.tableview.frame = self.view.bounds
        self.tableview.frame.origin.y = searchBar.frame.origin.y + searchBar.height
        tableview.height -= self.topLayoutGuide.length
        tableview.height -= self.bottomLayoutGuide.length
        tableview.height -= searchBar.height

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = 40;
        self.tableview.sectionHeaderHeight = 30

        // Do any additional setup after loading the view.
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        keyboard.endEditing()
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
    
    func refreshData(){
        sendReq("")
    }

    func sendReq(var searchText:String){
        self.taskImport0.removeAll(keepCapacity: false)
        self.taskImport1.removeAll(keepCapacity: false)
        self.taskImport2.removeAll(keepCapacity: false)
        self.taskImport3.removeAll(keepCapacity: false)
        var msgReq = PkgTaskPageQueryReq.builder()
        msgReq.taskflag = PkgTaskPageQueryReq.EnTaskFlag.TfMytask
        msgReq.pageflag = PkgTaskPageQueryReq.EnPageFlag.PReturnall
        msgReq.enconditon = PkgTaskPageQueryReq.EnTaskQueryCondition.TqcTasknotstatus.rawValue
        var condition = PkgTaskPageQueryReq.PkgTaskQueryCondition.builder()

        if(searchText != ""){
            var cd1 = PkgTaskPageQueryReq.EnTaskQueryCondition.TqcKeyforname.rawValue
            var cd2 = PkgTaskPageQueryReq.EnTaskQueryCondition.TqcKeyforcontent.rawValue

            msgReq.enconditon = msgReq.enconditon | cd1 | cd2
            condition.keyforname = searchText
            condition.keyforcontent = searchText
        }
     
        condition.taskstatuslist.append(PkgTaskInfo.EnTaskStatus.TsFinished.rawValue)
        msgReq.pkgtaskquerycondition = condition.build()
        var msgReply = PkgTaskPageQueryReply.builder()
        
        GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
        
       
        for taskinfo in msgReply.taskinfolist{
            var taskbuilder = PkgTaskInfo.builder()
            taskbuilder.mergeFrom(taskinfo)
            if(Globals.shared.isMyTaskNotFinished(taskbuilder) && taskbuilder.taskdate != NSDate().formatted("YYYY-MM-dd")) {
                switch taskinfo.tasklevel {
                case PkgTaskInfo.EnTaskLevel.TlImportanceArgency:
                    self.taskImport0.append(taskbuilder)
                case PkgTaskInfo.EnTaskLevel.TlImportanceNotargency:
                    self.taskImport1.append(taskbuilder)
                case PkgTaskInfo.EnTaskLevel.TlNotimportanceArgency:
                    self.taskImport2.append(taskbuilder)
                case PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency:
                    self.taskImport3.append(taskbuilder)
                default:
                    break
                }
            }

        }
        //排序
        sort(&self.taskImport0,
            {taskinfo1,taskinfo2 in
                if(taskinfo1.status != taskinfo2.status){
                    return taskinfo1.status.rawValue < taskinfo2.status.rawValue
                }
                if(taskinfo1.createtime != taskinfo2.createtime){
                    return taskinfo1.createtime > taskinfo2.createtime
                }
                return true;
        })
        sort(&self.taskImport1,
            {taskinfo1,taskinfo2 in
                if(taskinfo1.status != taskinfo2.status){
                    return taskinfo1.status.rawValue < taskinfo2.status.rawValue
                }
                if(taskinfo1.createtime != taskinfo2.createtime){
                    return taskinfo1.createtime > taskinfo2.createtime
                }
                return true;
        })
        sort(&self.taskImport2,
            {taskinfo1,taskinfo2 in
                if(taskinfo1.status != taskinfo2.status){
                    return taskinfo1.status.rawValue < taskinfo2.status.rawValue
                }
                if(taskinfo1.createtime != taskinfo2.createtime){
                    return taskinfo1.createtime > taskinfo2.createtime
                }
                return true;
        })
        sort(&self.taskImport3,
            {taskinfo1,taskinfo2 in
                if(taskinfo1.status != taskinfo2.status){
                    return taskinfo1.status.rawValue < taskinfo2.status.rawValue
                }
                if(taskinfo1.createtime != taskinfo2.createtime){
                    return taskinfo1.createtime > taskinfo2.createtime
                }
                return true;
        })
        self.tableview!.reloadData()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var tableview:UITableView!
    
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickSave(sender: AnyObject) {
        var indexPath:NSIndexPath? = self.tableview.indexPathForSelectedRow()
        if( indexPath != nil){
            if let taskinfo = indexToTask(indexPath!.section,indexrow: indexPath!.row){
                self.delegate?.onTaskChoosed(taskinfo)
                navigationController?.popViewControllerAnimated(true)
            }
        }
 
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String{
     
        if( section < taskSection.count){
            return taskSection[section]
        }

        return ""
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return taskSection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CELL_ID = "CELLID"
        var cell : UITableViewCell?
        cell  = tableview.dequeueReusableCellWithIdentifier(CELL_ID) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,reuseIdentifier: CELL_ID)
        }
        
        if let taskinfo = indexToTask(indexPath.section,indexrow: indexPath.row){
            cell?.textLabel.text = taskinfo.name
        }
     
        return cell!
    }
    
    
    private func indexToTask(indexsection:Int,indexrow:Int) -> PkgTaskInfoBuilder?{
        var taskinfo:PkgTaskInfoBuilder?
        switch(indexsection - 1){
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
        switch(section - 1){
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
    }

     func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchtext = searchBar.text
        doSearch(searchBar,searchtext:searchtext)
        keyboard.endEditing()
    }
    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar){
//       // searchBar.setShowsCancelButton(false, animated: true)
//        refreshData()
//    }
    
    func searchBar(searchBar: UISearchBar,textDidChange searchText: String){
        
        doSearch(searchBar,searchtext:searchText)
    }

    
    func doSearch(searchBar: UISearchBar,var searchtext :String){
     //   searchBar.setShowsCancelButton(true, animated: true)
        sendReq(searchtext)
    }

}
