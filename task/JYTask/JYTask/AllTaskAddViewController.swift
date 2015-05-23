//
//  AllTaskAddViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-20.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class AllTaskAddViewController: UIViewController,TaskSortControlDelegate,Import4ControlDelegate, UITextFieldDelegate{


    var popDatePicker : PopDatePicker?
    var curTaskCount:Int = 0
    
    
    @IBOutlet weak var taskContentField: CommentTextField!
    @IBOutlet weak var tasknameField: UITextField!
    @IBOutlet weak var taskdateField:UITextField!
    @IBOutlet weak var ctrlImport4: Import4Control!
    @IBOutlet weak var ctrlSortControl: TaskSortControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ctrlSortControl.delegate = self
        ctrlImport4.delegate = self
        popDatePicker = PopDatePicker(forTextField: taskdateField)
        taskdateField.delegate = self
        var curdate = NSDate()
        taskdateField.text = curdate.formatted("YYYY-MM-dd")
        
        // Do any additional setup after loading the view.
        var curTaskIndex = curTaskCount
        if curTaskCount > 6{
            curTaskIndex = 5
        }
        
        ctrlSortControl.setSortIndex(curTaskIndex, Count: curTaskCount + 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func onClickOK(sender: AnyObject) {
        
        //    self.dismissViewControllerAnimated(true, completion: nil)
    //    navigationController?.popViewControllerAnimated(true)
     //   return
        var msgReq = PkgTaskOperationReq.builder()
        msgReq.taskoperation  = PkgTaskOperationReq.EnTaskOperation.ToInsertInfo.toRaw()
        msgReq.taskinfo = getCurTaskInfo().build()
        
        println(msgReq.internalGetResult.description)
        msgAPI.sharedMsgAPI().sendMsg("comm.PkgTaskOperationReq",msgReq: msgReq.internalGetResult, block: {
            (isOK:Bool,rettypename:String,rethexdata:String?) ->Void in
            if isOK {
                
                var msgReply = PkgTaskOperationReply.builder()
                let hexData = _sharedMsgAPI.hexStringToData(rethexdata!)
                var buffer = [UInt8](count:hexData.length, repeatedValue:0)
                hexData.getBytes(&buffer, length:hexData.length)
                msgReply.mergeFromData(buffer)
                
                println(msgReply.internalGetResult.description)
                
                if msgReply.issuccess{
                    self.navigationController?.popViewControllerAnimated(true)
                    //  self.dismissViewControllerAnimated(true, completion: nil)
                    //self.performSegueWithIdentifier("logintoMainSegue", sender: self)
                    //logintoMainSegue
                    //  var appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    //  appDel.setAppviewAsRootView()
                }
                else{
                    
                }
            }
        })
        
    }
    
    func onClickSortBtnIndex(nSel:Int){
        println("TaskAddNewTaskViewController ctrlSortControl btn click:\(nSel)")
    }
    func onClickImport4BtnIndex(nSel:Int){
        println("TaskAddNewTaskViewController ctrlImport4 btn click:\(nSel)")
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField === taskdateField) {
            taskdateField.resignFirstResponder()
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            let initDate = formatter.dateFromString(taskdateField.text)
            
            popDatePicker!.pick(self, initDate:initDate, dataChanged: { (newDate : NSDate, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = newDate.formatted("YYYY-MM-dd")
                
            })
            return false
        }
        else {
            return true
        }
    }
    
    
    
    
    
    func getCurTaskInfo() -> PkgTaskInfoBuilder{
        var taskinfo = PkgTaskInfo.builder()
        taskinfo.name = tasknameField.text
        taskinfo.content = taskContentField.text
        taskinfo.sortorder = toString(ctrlSortControl.getSortIndex())
        switch(ctrlImport4){
        case 0:
            taskinfo.tasklevel = PkgTaskInfo.EnTaskLevel.TlImportanceArgency
        case 1:
            taskinfo.tasklevel = PkgTaskInfo.EnTaskLevel.TlImportanceNotargency
        case 2:
            taskinfo.tasklevel = PkgTaskInfo.EnTaskLevel.TlNotimportanceArgency
        case 3:
            taskinfo.tasklevel = PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency
        default:
            taskinfo.tasklevel = PkgTaskInfo.EnTaskLevel.TlNotimportanceNotargency
            
        }
        taskinfo.taskdate = taskdateField.text
        return taskinfo
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
