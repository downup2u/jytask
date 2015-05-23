//
//  MainTaskViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-8.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class MainTaskViewController: UIViewController  {

   
    @IBOutlet weak var segmentedControl: MESegmentedControl!

    @IBOutlet weak var uiPanel: UIView!
    var currentViewController: UIViewController?
    var currentIndex: Int?
    var allViewControllers: Array<UIViewController> = Array<UIViewController>()
    
    
      override func viewDidLoad() {
        super.viewDidLoad()
   
            self.segmentedControl.removeAllSegments()
            self.segmentedControl.exclusiveTouch = true
        
            self.segmentedControl.addTarget(
                self,
                action: "segmentedControlSelected:",
                forControlEvents: UIControlEvents.ValueChanged)
      

        
        var storyboard = UIStoryboard(name: "Task", bundle: nil)
        var todaytaskViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier("TaskView0") as! UIViewController
        var coworktaskViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier("TaskView1") as! UIViewController
        var alltaskViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier("TaskView2") as! UIViewController
        
    
        allViewControllers.append(todaytaskViewController)
        allViewControllers.append(coworktaskViewController)
        allViewControllers.append(alltaskViewController)
        
        var appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDel.taskViewController = self
        
        
        self.configWith()

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataChanged:", name: ONGETMSGREFRESHDATA, object: nil)
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onDataChanged(notification: NSNotification){
        var strtype: String = notification.object as! String
        if strtype == "allcoworktask"{
            refreshData()
        }
    }
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        refreshData()
    }
    override func viewDidDisappear(animated: Bool) {
       segmentedControl.clearBadges()
    }
    
    var gnotreaded:UInt = 0
    func refreshData(){
        dispatch_async(dispatch_get_main_queue(),{

            var msgReq = Comm.PkgTaskPageQueryReq.builder()
            msgReq.taskflag = Comm.PkgTaskPageQueryReq.EnTaskFlag.TfCoworktask
            msgReq.enconditon = Comm.PkgTaskPageQueryReq.EnTaskQueryCondition.TqcReadedflag.rawValue
            var condition = Comm.PkgTaskPageQueryReq.PkgTaskQueryCondition.builder()
            condition.enreadedflag = Comm.PkgTaskPageQueryReq.PkgTaskQueryCondition.EnReadedFlag.PrNotreaded
            msgReq.pkgtaskquerycondition = condition.build()
            msgReq.pageflag = Comm.PkgTaskPageQueryReq.EnPageFlag.POnlynum
            var msgReply = Comm.PkgTaskPageQueryReply.builder()
            GlobalTaskDataWrap.shared.sendsendWrapMsgTaskPageQuery(msgReq, msgReply: msgReply)
            self.gnotreaded = UInt(msgReply.returnnum)
        
        //    dispatch_sync(dispatch_get_main_queue(),{
                self.segmentedControl.setBadgeNumber(self.gnotreaded,forSegmentAtIndex:1)
        //    });
        });

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func unwindToMainTaskViewController(unwindSegue: UIStoryboardSegue){
        println("unwindToMainTaskViewController")
    }
  
    
    func segmentedControlSelected(sender: UISegmentedControl!) -> Void {
        if sender.selectedSegmentIndex != self.currentIndex {
            transitionFromOldIndexToNewIndex(self.currentIndex, newIndex: sender.selectedSegmentIndex)
        }
    }
    //----------------------------------------------------------------------------------------------------------------//
    override func viewDidLayoutSubviews(){
   //     self.view.layoutMargins = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0)
        self.uiPanel.frame = self.view.bounds
//        if let bottombarheight = self.tabBarController?.tabBar.bounds.height{
//            uiPanel.height -= bottombarheight
//        }
        uiPanel.frame.origin.y = self.topLayoutGuide.length
        uiPanel.height -= self.topLayoutGuide.length
        uiPanel.height -= self.bottomLayoutGuide.length
        for (var i = 0 ;i < allViewControllers.count ;i++)
        {
            allViewControllers[i].view.frame = self.uiPanel.bounds
        }
        //println("today viewDidLayoutSubviews:\(self.view.frame),\(self.tableview.frame)")
    }
    func transitionFromOldIndexToNewIndex(oldIndex: Int!, newIndex: Int!) -> Void {
        let visibleViewController = self.allViewControllers[oldIndex] as UIViewController
        let newViewController = self.allViewControllers[newIndex] as UIViewController
        visibleViewController.view.hidden = true
        newViewController.view.hidden = false
        self.currentViewController = newViewController
        self.currentIndex = newIndex
     
    }
    

    
    func configWith() -> Void {
        
        var titles = [String]()
        for viewController: UIViewController in allViewControllers {
            titles.append(viewController.title!)
        }
        addTheSegmentTitles(titles)
        println("\(titles),\(allViewControllers.count),\(self.uiPanel)")
        var initSel = 0
        self.segmentedControl.selectedSegmentIndex = initSel
        self.currentIndex = initSel
        
       
    
        self.currentViewController = self.allViewControllers[initSel]

        for (var i = 0 ;i < allViewControllers.count ;i++)
        {
          //  allViewControllers[i].view.frame = self.uiPanel.bounds
            addChildViewController(allViewControllers[i])
            self.uiPanel.addSubview(allViewControllers[i].view)
            if( i > 0){
                allViewControllers[i].view.hidden = true
            }
        }

        self.allViewControllers[initSel].didMoveToParentViewController(self)
        
        
    }
    
    
    func addTheSegmentTitles(titles: Array<String>!) -> Void {
        for title: String in titles {
            self.segmentedControl.insertSegmentWithTitle(
                title,
                atIndex: self.segmentedControl.numberOfSegments,
                animated: false)
        }

    }
    
}
