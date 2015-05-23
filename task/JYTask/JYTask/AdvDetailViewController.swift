//
//  AdvDetailViewController.swift
//  JYTask
//
//  Created by wxqdev on 14-10-28.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

class AdvDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = advinfo.name
        println("picurl:\(advinfo.urlpic)")
//        var defaultImg = UIImage(named:"loginLogo")
//        self.advImage.setImage(advinfo.urlpic,placeHolder: defaultImg)
//       
        //self.advContent.userInteractionEnabled = false
        self.advContent.opaque = false
        self.advContent.backgroundColor = UIColor.clearColor()
        self.advContent.loadHTMLString(advinfo.advtxt, baseURL: nil)
        // Do any additional setup after loading the view.
    }
    var advinfo: Comm.PkgAdvInfo = Comm.PkgAdvInfo()
   
    @IBOutlet weak var advContent: UIWebView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func onClickReturn(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
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
