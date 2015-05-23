//
//  TaskChooseMembersViewController.swift
//  JYTask
//
//  Created by wxqdev on 14-10-24.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

class TaskChooseMembersViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    var bartitle:String = "选择人员"
    var delegate:TaskUserChooseDelegate?

    @IBOutlet weak var btnOK: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.memberstable.delegate = self
        self.memberstable.dataSource = self
        self.navigationItem.title = bartitle
        
        self.searchBar.delegate = self
        self.searchBar.placeholder = "请输入要搜索的人员姓名"
       // self.searchBar. = true
        btnOK.enabled = false

        refreshData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)
        
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
        if strtype == "groupuser" {
            refreshData()
        }
    }
    
    func refreshData(){
        self.groupArray = Globals.shared.groupArray
        self.userArray = Globals.shared.userArray
        self.memberstable.reloadData()
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var memberstable: UITableView!
    var groupArray = [Comm.PkgCompanyGroup()]
    var userArray = [Comm.PkgGroupUser()]
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
    }
    @IBAction func onClickReturn(sender: AnyObject) {
         navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func onClickOK(sender: AnyObject) {
        var indexPath:NSIndexPath? = self.memberstable.indexPathForSelectedRow()
        if( indexPath != nil){
            self.delegate?.onUserChoosed(userArray[indexPath!.row].userid,username:userArray[indexPath!.row].realname)
            navigationController?.popViewControllerAnimated(true)

        }
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if Int(userArray[indexPath.row].userid) == Globals.shared.userid {
            //btnOK.enabled = false
            return nil
        }
        btnOK.enabled = true
        return indexPath
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CELL_ID = "CELLID"
        var cell : UITableViewCell?
        cell  = memberstable.dequeueReusableCellWithIdentifier(CELL_ID) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,reuseIdentifier: CELL_ID)
        }
        
        
        if(self.userArray.count > indexPath.row){
            cell?.textLabel?.text = userArray[indexPath.row].realname
            if Int(userArray[indexPath.row].userid) == Globals.shared.userid {
                cell?.textLabel?.textColor = UIColor.grayColor()
            }
            else{
                cell?.textLabel?.textColor = UIColor.blackColor()
            }
        }
        
        return cell!
        
        
    }
    
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return userArray.count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchtext = searchBar.text
        doSearch(searchBar,searchtext:searchtext)
        keyboard.endEditing()
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
        /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    

    
    

}
