//
//  AdvListViewController.swift
//  JYTask
//
//  Created by wxqdev on 14-10-28.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

class AdvListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        //add default
        var adv = Comm.PkgAdvInfo()
        self.advArray.append(adv)
        
        loadadvs()
        // Do any additional setup after loading the view.
    }
    var advArray = [Comm.PkgAdvInfo()]
    @IBOutlet weak var advtable: UITableView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadadvs(){
        
        var msgReq = Comm.PkgAdvQueryReq.builder()
        msgReq.queryflag = Comm.PkgAdvQueryReq.EnQueryType.QtSpnum.rawValue | Comm.PkgAdvQueryReq.EnQueryType.QtVaildtime.rawValue
        msgReq.numreq = 10
        var msgReply = Comm.PkgAdvQueryReply.builder()
        sendProtobufMsg(msgReq,msgReply,self.view,{
            (isOK:Bool,err:String?) ->Void in
            var bGetData = false
            var errString:String = ""
            if let errret = err{
                errString = errret
            }
            if isOK{
                if(msgReply.issuccess){
                    if(msgReply.advinfolist.count > 0){
                        self.advArray.removeAll(keepCapacity: true)
                        for adv in msgReply.advinfolist{
                            self.advArray.append(adv)
                        }
                        bGetData = true
                    }
                }
                else{
                    errString = msgReply.err
                    
                }
                
            }
            else{
              
                errString = err!
            }
            
//            if(bError){
//                SCLAlertView().showError(self, title: "", subTitle: errString, closeButtonTitle:NSLocalizedString("OK", comment:"确定"))
//            }
            if(bGetData){
                self.advtable!.reloadData()
            }
        })

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CELL_ID = "celladv"
        var cell : UITableViewCell?
        cell  = advtable.dequeueReusableCellWithIdentifier(CELL_ID) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,reuseIdentifier: CELL_ID)
        }
        var imageview = cell?.viewWithTag(1001) as! UIImageView
        
        if(advArray.count > indexPath.row){
           // cell?.textLabel?.text = advArray[indexPath.row].name
            var defaultImg = UIImage(named:"1")
           // self.advImage.setImage(advinfo.urlpic,placeHolder: defaultImg)
            imageview.setImage(advArray[indexPath.row].urlpic,placeHolder: defaultImg)
        }
        
        return cell!
       
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.advArray.count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if(advArray.count > indexPath.row )
        {
            if(advArray[indexPath.row].urlpic != ""){
                self.performSegueWithIdentifier("toadvdetailSegue", sender: indexPath.row)
            }
        }
       
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toadvdetailSegue"{
            var dvc:AdvDetailViewController = segue.destinationViewController as! AdvDetailViewController
           
            dvc.advinfo = advArray[sender as! Int]
        }
     
        
    }

}
