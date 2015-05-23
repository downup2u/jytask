//
//  ResetPasswordOKViewController.swift
//  JYTask
//
//  Created by wxqdev on 14-10-27.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

class ResetPasswordOKViewController: UIViewController {
    @IBOutlet weak var btnOK: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = nil
        //self.navigationController?.navigationBarHidden = true
        addButtonCorner_OK(btnOK)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickOK(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
