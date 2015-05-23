//
//  MyInfoAboutViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-17.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class MyInfoAboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        labelcurversion.text = NSLocalizedString("CurrentVersion", comment:"当前版本:") + Globals.shared.version
        
        addButtonCorner_OK(btndownloadlatest)
        btndownloadlatest.setBackgroundImage(UIImage.imageWithColor(UIColor.grayColor()), forState: UIControlState.Disabled)
        btndownloadlatest.setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHex("#1E90FF")), forState: UIControlState.Normal)
        if Globals.shared.version == Globals.shared.lastestversion{
            btndownloadlatest.enabled = false
            btndownloadlatest.setTitle(NSLocalizedString("CurrentAlreadyLastestVersion",comment:"当前已经是最新版本"), forState:UIControlState.Disabled)
            
        }
        else{
            btndownloadlatest.enabled = true
            btndownloadlatest.setTitle(NSLocalizedString("DownloadLastestVersion",comment:"下载最新版本")+"\(Globals.shared.lastestversion)", forState:UIControlState.Normal)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var labelcurversion: UILabel!
    @IBOutlet weak var btndownloadlatest: UIButton!
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickCheckVersion(sender: AnyObject) {
        var url:NSURL = NSURL(string: Globals.shared.lastestversiondownloadurl)!
        UIApplication.sharedApplication().openURL(url)
//        SCLAlertView().showNotice(self, title: "", subTitle: "弹出页面到\(Globals.shared.lastestversiondownloadurl)下载新版本", closeButtonTitle:NSLocalizedString("OK", comment:"确定"))

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
