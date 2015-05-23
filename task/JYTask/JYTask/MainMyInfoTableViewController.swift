//
//  MainMyInfoTableViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-8.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class MainMyInfoTableViewController: UITableViewController {

      
    @IBOutlet weak var myprofiletable: UITableView!
    var dataRowArr:NSArray!
    var dataSectionArr:NSArray!
    var btnLogout:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonCorner_Red(btnLogout)
        
        dataRowArr = NSArray(contentsOfURL: NSBundle.mainBundle().URLForResource("taskmyprofile", withExtension: "plist")!)
        dataSectionArr = NSArray(contentsOfURL:NSBundle.mainBundle().URLForResource("taskmyprofilesection", withExtension: "plist")!)


        var view = UIView(frame: CGRectMake(0, 0, self.myprofiletable.bounds.width, 45))
        btnLogout.addTarget(self, action: "onClickLogout:", forControlEvents: UIControlEvents.TouchUpInside)
        btnLogout.setTitle("退出", forState: UIControlState.Normal)
        btnLogout.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(btnLogout)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[btn]-10-|", options: nil, metrics: nil, views:["btn":btnLogout]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[btn]|",options:nil, metrics:nil, views:["btn":btnLogout]))
        self.myprofiletable.tableFooterView = view

        
        refreshData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func onDataChanged(notification: NSNotification){
        var strtype: String = notification.object as! String
        if strtype == "companyinfo" || strtype == "tasknumber"
            || strtype == "memberrole" || strtype == "latestversion" {
            refreshData()
        }
    }
    
    func refreshData(){
        self.myprofiletable.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataRowArr.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell :AnyObject! = nil
        if(indexPath.section < dataRowArr.count){
       
            let dict = (dataRowArr[indexPath.section] as! NSArray).objectAtIndex(indexPath.row) as! NSDictionary
            var tagtype:Int = dict["tagtype"] as! Int
            var label0value:String? = dict["label0"] as! String?
            var label1value:String? = dict["label1"] as! String?
            println("tagtype:\(tagtype),value0:\(label0value),value1:\(label1value)")
            cell = tableView.dequeueReusableCellWithIdentifier("cell\(tagtype)")
            
            var labeltag = tagtype*10 + 1
            var label0 = cell.viewWithTag(labeltag) as! UILabel
            label0.text = label0value
            if(tagtype == 1 || tagtype == 2)
            {
                var label1 = cell.viewWithTag(labeltag+1) as! UILabel
                label1.text = label1value!
            }
       
            
            if(tagtype == 1 || tagtype == 2){
                var label1 = cell.viewWithTag(labeltag+1) as! UILabel
                if(indexPath.section == 0){
                    if(indexPath.row == 0){
                        //真实名
                        label1.text = Globals.shared.realname
                    }
                    if(indexPath.row == 1){
                        //账号名
                        label1.text = Globals.shared.phonenumber
                    }
                }
                
                if(indexPath.section == 1){
                    if(indexPath.row == 0){
                        //所在组织
                        if Globals.shared.companyid > 0 {
                            label0.text = Globals.shared.companyname
                            label1.text = "查看"
                        }
                        else{
                            label0.text = "暂无组织"
                            label1.text = "加入／创建组织"
                            
                        }
                    }
                    
                    if(indexPath.row == 1){
                        label1.text = Globals.shared.rolename
                        
                    }
                    
                }

                
                if(indexPath.section == 2 ){
                    if(indexPath.row == 0){
                        label1.text = toString(Globals.shared.tasknumbernotfinished)
                        //未完成任务数
                        println("未完成任务数")
                    }
                    
                    if(indexPath.row == 1){
                        //已完成任务数
                        label1.text = toString(Globals.shared.tasknumberfinished)
                        println("已完成任务数")
                    }
                }
                
                

                
                if(indexPath.section == 3){
                    if(indexPath.row == 0){
                        //软件版本
                        label1.text = toString(Globals.shared.version)
                        println("软件版本")
                        
                    }
                    
                    if(indexPath.row == 1){
                        //注册时间
                        label1.text = Globals.shared.usercreatetime
                        println("注册时间")
                        
                    }


                    
                }
            }
            
        }
        return cell as! UITableViewCell

        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        var sectionTitle:String = dataSectionArr[section] as! String
        println(sectionTitle)
        return sectionTitle
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataRowArr[section] as! NSArray).count
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
     
        if(indexPath.section < dataRowArr.count){
            let section = indexPath.section
            let dict = (dataRowArr[indexPath.section] as! NSArray).objectAtIndex(indexPath.row) as! NSDictionary
            var tagtype:Int = dict["tagtype"] as! Int
            if(tagtype == 2){
                if(section == 0 && indexPath.row == 2){
                    //修改密码
                    println("修改密码")
                    self.performSegueWithIdentifier("toUpdatePasswordSegue", sender: self)
                }
                
                if(section == 1 && indexPath.row == 0){
                    //创建／加入组织
                    println("创建／加入组织")
                    if Globals.shared.companyid > 0 {//"常州简易软件有限公司"->"查看"
                        
                            self.performSegueWithIdentifier("toCompanyAdminSegue", sender: self)
                  
                    }
                    else{//"暂无组织"->"加入／创建组织"
                        
                        self.performSegueWithIdentifier("toCreateCompanySegue", sender: self) 
                        
                    }

                }
                
                if(section == 2 && indexPath.row == 0){
                    //未完成任务数
                    println("未完成任务数")
                    var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
                    var tasklistvc = storyBoardTask.instantiateViewControllerWithIdentifier("tasklist") as! TaskAllFinishedTaskViewController
                    tasklistvc.taskFlag = TaskFlag.TaskNotFinished
                    navigationController?.pushViewController(tasklistvc,animated: true)
                }
                
                if(section == 2 && indexPath.row == 1){
                    //已完成任务数
                    println("已完成任务数")
                    var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
                    var tasklistvc = storyBoardTask.instantiateViewControllerWithIdentifier("tasklist") as! TaskAllFinishedTaskViewController
                    tasklistvc.taskFlag = TaskFlag.TaskAllFinished
                    navigationController?.pushViewController(tasklistvc,animated: true)

                }
                
                if(section == 3 && indexPath.row == 0){
                    //软件版本
                    println("软件版本")
                    GlobalMsgReqUtil.shared.sendVersion()
                    self.performSegueWithIdentifier("toAboutSegue", sender: self)
                }
            }
        }
    }
    
    @IBAction func onClickLogout(sender: AnyObject) {
        var appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDel.setLoginViewAsRootView()
    }


}
