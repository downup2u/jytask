//
//  MyInfoCompanyMemberManagerViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-17.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class MyInfoCompanyMemberManagerViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.memberstable.delegate = self
        self.memberstable.dataSource = self
        
        
        btnDeleteUser.setTitleColor(UIColor.blackColor(),forState:UIControlState.Disabled)
      //  btnDeleteUser.setTitleColor(UIColor.whiteColor(),forState:UIControlState.Normal)
        btnDeleteUser.setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHex("#EBEBEB")), forState: UIControlState.Disabled)
       // btnDeleteUser.setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHex("#1E90FF")), forState: UIControlState.Normal)
        
        addButtonCorner_Red(btnDeleteUser)
        
        if(Globals.shared.isAdmin()){
          //  self.memberstable.sectionFooterHeight = 40
            
  
            var view = UIView(frame: CGRectMake(0, 0, self.memberstable.bounds.width, 45))
            btnDeleteUser.enabled = false
            btnDeleteUser.addTarget(self, action: "onDeleteButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            btnDeleteUser.setTitle("删除成员", forState: UIControlState.Normal)
            btnDeleteUser.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.addSubview(btnDeleteUser)
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[btn]-10-|", options: nil, metrics: nil, views:["btn":btnDeleteUser]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[btn]|",options:nil, metrics:nil, views:["btn":btnDeleteUser]))
           
            
            
            self.memberstable.tableFooterView = view

        }
   
        
        refreshData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)
        
        if(!Globals.shared.isAdmin()){
            self.navigationItem.rightBarButtonItem = nil
        }
        self.searchBar.delegate = self
        self.searchBar.placeholder = "请输入要搜索的人员姓名"

    }


    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onDataChanged(notification: NSNotification){
        var strtype: String = notification.object as! String
        if strtype == "groupuser" {
            refreshData()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    var groupArray = [Comm.PkgCompanyGroup()]
    var userArray = [Comm.PkgGroupUser()]
    var selArrayUsers:Array<Comm.PkgGroupUser> = Array<Comm.PkgGroupUser>()
    @IBOutlet weak var memberstable: UITableView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    
    func refreshData(){
        self.groupArray = Globals.shared.groupArray
        self.userArray = Globals.shared.userArray
        self.memberstable.reloadData()
        if(self.userArray.count > 1){
            btnDeleteUser.hidden = false
        }
        else{
            btnDeleteUser.hidden = true
        }

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

            var celluser : AnyObject! = tableView.dequeueReusableCellWithIdentifier("celluser")
            
            var   labelphonenumber = celluser.viewWithTag(1001) as! UILabel
            var   labelname = celluser.viewWithTag(1002) as! UILabel
            var   checkbtn = celluser.viewWithTag(1003) as! UIButton
            var   adminbtn = celluser.viewWithTag(1004) as! UIButton
            addButtonCheckBox(checkbtn,UIImage(named: "loginRememberPwd")!,UIImage(named: "loginRememberPwdChecked")!)
            checkbtn.layer.setValue(indexPath.row, forKey: "userindex")
            checkbtn.layer.setValue(tableView, forKey: "tableView")
            if( Globals.shared.isAdmin()){
                checkbtn.addTarget(self, action: "onCheckButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
                checkbtn.hidden = false
            }
            else{
                checkbtn.hidden = true
            }
            
            if(self.userArray.count > indexPath.row){
                labelphonenumber.text = self.userArray[indexPath.row].phonenumber
                labelname.text = self.userArray[indexPath.row].realname
                
                labelphonenumber.textColor = UIColor.blackColor()
                labelname.textColor = UIColor.blackColor()
                
                if(Int(self.userArray[indexPath.row].userid) == Globals.shared.userid ){
                    labelphonenumber.textColor = UIColor.grayColor()
                    labelname.textColor = UIColor.grayColor()
                    checkbtn.hidden = true
                    
                }
                
                if( self.userArray[indexPath.row].permissionroleid == 2){
                    labelphonenumber.textColor = UIColor.blueColor()
                    labelname.textColor = UIColor.blueColor()
                    adminbtn.hidden = false
                }
                else{
                    adminbtn.hidden = true
                }
            }
            
            return celluser as! UITableViewCell

        
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if Int(self.userArray[indexPath.row].userid) == Globals.shared.userid {
            return nil
        }
        return indexPath
    }
    
    @IBAction func onCheckButtonClicked(sender: AnyObject) {
        var   checkbtn = sender as! UIButton
        checkbtn.selected = !checkbtn.selected
        let index = sender.layer.valueForKey("userindex") as! Int
        if(checkbtn.selected){
            selArrayUsers.append(self.userArray[index])
        }
        else{
            for(var i:Int = 0 ;i < self.selArrayUsers.count ;i++ ){
                if self.selArrayUsers[i].userid == self.userArray[index].userid{
                    self.selArrayUsers.removeAtIndex(i)
                    break
                }
            }
        }
        println("\(self.selArrayUsers)")
       if(Globals.shared.isAdmin()){
        
           var tableView = sender.layer.valueForKey("tableView") as! UITableView
           var celldelete : AnyObject! = tableView.dequeueReusableCellWithIdentifier("celldelete")
           //var deletebtn = celldelete.viewWithTag(1000) as UIButton
            btnDeleteUser.enabled = selArrayUsers.count > 0 ? true : false
        
        }
    }
   
    var btnDeleteUser:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    
    @IBAction func onDeleteButtonClicked(sender: AnyObject) {
        
        if self.selArrayUsers.count == 0{
            showWarning("","至少选中一名成员")
            return
        }
        let alert = SCLAlertView()
        alert.addButton("确定", target:self, selector:Selector("deletefromcompany"))
        alert.showWarning("", subTitle: "你确信要删除这些成员吗?该操作不能恢复", closeButtonTitle:"取消")

         //deleteuserfromCompany()
    }
    
    func deletefromcompany(){

        var msgReq = Comm.PkgUserDeleteFromCompanyReq.builder()
        for user in self.selArrayUsers{
            msgReq.useridlist.append(user.userid)
        }
        var msgReply = Comm.PkgUserDeleteFromCompanyReply.builder()
        
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bError = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                if(msgReply.issuccess){
                    Globals.shared.companynumber = Int(msgReply.companyusernumber)
                    GlobalMsgReqUtil.shared.sendGroupUserReq()
                    NSNotificationCenter.defaultCenter().postNotificationName(ONGETMSGREFRESHDATA, object: "companyinfo")
                    var okString = "删除组织成员成功"
                    showSuccess("", okString)
                    self.navigationController?.popViewControllerAnimated(true)


                    
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
        })

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.userArray.count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchtext = searchBar.text
        doSearch(searchBar,searchtext:searchtext)
    }
    
    
    func searchBar(searchBar: UISearchBar,textDidChange searchText: String){
        
        doSearch(searchBar,searchtext:searchText)
    }
    
    
    func doSearch(searchBar: UISearchBar,var searchtext :String){
        //   searchBar.setShowsCancelButton(true, animated: true)
        self.userArray.removeAll(keepCapacity: true)
        for userbuilder in Globals.shared.userArray{
            if(searchtext == ""){
                self.userArray.append(userbuilder)
            }
            else{
                
                if let srange = userbuilder.realname.rangeOfString(searchtext){
                    self.userArray.append(userbuilder)
                }
            }
            
        }
        self.memberstable.reloadData()
        
    }
}
