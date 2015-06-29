//
//  AppDelegate.swift
//  WorkTest
//
//  Created by wxqdev on 14-9-29.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit
//import ProtocolBuffers
import CoreData
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var taskViewController:UIViewController?
    var taskNav:UINavigationController?

    func documentsDir() -> String {
        let array = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        if array.count > 0 {
            return array.objectAtIndex(0) as! String
        }
        return ""
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // setAppviewAsRootView
        IQKeyboardManager.sharedManager().enable = true
        
        var sIn:String = documentsDir()
        var dbname = Globals.shared.urlWebService.md5
        sIn += "/\(dbname)_v2"
        OCWrap.initDB(sIn)
        return true
    }

    func setLoginViewAsRootView(){
        Globals.shared.logoutClearData()
        var storyBoard = UIStoryboard(name:"Main",bundle:nil)
        var loginNav = storyBoard.instantiateViewControllerWithIdentifier("mainLoginNav") as! UINavigationController
        self.window!.rootViewController = loginNav
      
        
        
    }
    
    func setAppviewAsRootView(){
        GlobalMsgReqUtil.shared.loginSuccessSendReq()
        var storyBoardTask = UIStoryboard(name:"Task",bundle:nil)
        var AppNav = storyBoardTask.instantiateViewControllerWithIdentifier("mainAppNav") as! UITabBarController
       
        if let arrayViews = AppNav.viewControllers {
 
        }
        else{
           var taskRoot = storyBoardTask.instantiateViewControllerWithIdentifier("taskNav") as! UINavigationController
            taskNav = taskRoot
            var storyBoardAdv = UIStoryboard(name:"Adv",bundle:nil)
            var advRoot = storyBoardAdv.instantiateViewControllerWithIdentifier("advNav") as! UINavigationController
            
            var storoyBoardmyProfile = UIStoryboard(name:"MyProfile",bundle:nil)
            var myprofileRoot = storoyBoardmyProfile.instantiateViewControllerWithIdentifier("myProfileNav") as! UINavigationController
            
            AppNav.viewControllers = [taskRoot,advRoot,myprofileRoot]
            //= Array<UINavigationController>[taskRoot,advRoot,myprofileRoot]
        }
        self.window!.rootViewController = AppNav
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

