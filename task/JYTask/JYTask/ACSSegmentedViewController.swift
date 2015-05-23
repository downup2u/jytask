//
//  ACSSegmentedViewController.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-16.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//


import UIKit

class ACSSegmentedViewController: UIViewController {
    
    var segmentedControl: UISegmentedControl!
    var currentViewController: UIViewController?
    var currentIndex: Int?
  	var allViewControllers: Array<UIViewController> = Array<UIViewController>()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
         if (nil == self.segmentedControl) {
            self.segmentedControl = UISegmentedControl()
            self.segmentedControl.exclusiveTouch = true
            self.navigationItem.titleView = self.segmentedControl
            self.segmentedControl.addTarget(
                self,
                action: "segmentedControlSelected:",
                forControlEvents: UIControlEvents.ValueChanged)
           // self.view.addSubview(self.segmentedControl)
        }
      //  self.view.addSubview(contentView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //----------------------------------------------------------------------------------------------------------------//
    
    
    //- Action Method --------------------------------------------------------------------------------------------------
    func segmentedControlSelected(sender: UISegmentedControl!) -> Void {
        if sender.selectedSegmentIndex != self.currentIndex {
            transitionFromOldIndexToNewIndex(self.currentIndex, newIndex: sender.selectedSegmentIndex)
        }
    }
    //----------------------------------------------------------------------------------------------------------------//
    
    func transitionFromOldIndexToNewIndex(oldIndex: Int!, newIndex: Int!) -> Void {
        let visibleViewController = self.allViewControllers[oldIndex] as UIViewController
        let newViewController = self.allViewControllers[newIndex] as UIViewController

        var topHeight = self.segmentedControl.height//self.navigationController!.navigationBar.frame.size.height
        var onScreenFrame = view.frame
        onScreenFrame.size.height -= topHeight
        onScreenFrame.origin.y += topHeight
      //  onScreenFrame.size.height -= topHeight
       
        var offScreenFrame = onScreenFrame
        offScreenFrame.origin.y += offScreenFrame.height
        
        visibleViewController.willMoveToParentViewController(nil)
       // newViewController.view.frame = onScreenFrame
        addChildViewController(newViewController)
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        self.transitionFromViewController(
            visibleViewController,
            toViewController: newViewController,
            duration: 0,
            options: UIViewAnimationOptions.allZeros,
            animations: { () -> Void in
               // visibleViewController.view.frame = offScreenFrame
            },
            completion: { (finished: Bool) -> Void in
                self.currentViewController = newViewController
                self.currentIndex = newIndex
                
                visibleViewController.view.removeFromSuperview()
                
                self.view.addSubview(newViewController.view)
                newViewController.didMoveToParentViewController(self)
              //  newViewController.view.frame = offScreenFrame
               // newViewController.view.frame = onScreenFrame
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                  //  newViewController.view.frame = onScreenFrame
                    }, completion: { (Bool) -> Void in
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                })

            }
        )
    }
    
    //- Config Methods -------------------------------------------------------------------------------------------------
    func configWith(viewControllers: Array<UIViewController>!) -> Void {
        addTheChildViewControllers(viewControllers)
        
        var titles = [String]()
        for viewController: UIViewController in viewControllers {
            titles.append(viewController.title!)
        }
        configWith(viewControllers,titles:titles)
        
      
    }
    
    func configWith(viewControllers: Array<UIViewController>!, titles: Array<String>!) -> Void {
       
        addTheChildViewControllers(viewControllers)
        addTheSegmentTitles(titles)

        var initSel = 0
        self.segmentedControl.selectedSegmentIndex = initSel
        self.currentIndex = initSel
        self.currentViewController = self.allViewControllers[initSel]
        
        let viewController = allViewControllers[initSel]
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        

        
        
    }
    
    func addTheChildViewControllers(viewControllers: Array<UIViewController>!) -> Void {
        for viewController: UIViewController in viewControllers {
            allViewControllers.append(viewController)
        }
    }
    
    func addTheSegmentTitles(titles: Array<String>!) -> Void {
        for title: String in titles {
            self.segmentedControl.insertSegmentWithTitle(
                title,
                atIndex: self.segmentedControl.numberOfSegments,
                animated: false)
        }
        self.segmentedControl.sizeToFit()
        self.segmentedControl.width = self.segmentedControl.width*2
    }
    //----------------------------------------------------------------------------------------------------------------//
    
}
