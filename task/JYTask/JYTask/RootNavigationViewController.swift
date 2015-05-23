//
//  RootNavigationViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-15.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class RootNavigationViewController: UINavigationController ,UINavigationControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationController(navigationController: UINavigationController,
        willShowViewController viewController: UIViewController,
        animated: Bool){
            if(viewController is LoginViewController
                //|| viewController is FinishRegisterViewController
                ){
                self.navigationBarHidden = true
            }
            else if(viewController is MainTaskViewController){
                viewController.navigationItem.leftBarButtonItem = nil
                viewController.navigationItem.hidesBackButton = true
                viewController.navigationItem.rightBarButtonItem = nil
                //self.navigationBarHidden = true
            }
            else{
                if(self.navigationBarHidden){
                    self.navigationBarHidden = false
                }
            }
        // MainTaskViewController
            
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
