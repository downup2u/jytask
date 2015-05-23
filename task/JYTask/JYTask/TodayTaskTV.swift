//
//  TodayTaskTV.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-10.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import UIKit

class TodayTaskTV: UITableView ,UITableViewDataSource,UITableViewDelegate{

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    let TAG_CELL_IMAGELABEL = 1
    let TAG_CELL_TEXTLABEL = 2
    
    
    var data:NSDictionary!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        data = NSDictionary(contentsOfURL: NSBundle.mainBundle().URLForResource("taskdata", withExtension: "plist")!)
        
        self.dataSource = self
        self.delegate = self
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : AnyObject! = tableView.dequeueReusableCellWithIdentifier("celltask")
        
        var label = cell.viewWithTag(TAG_CELL_TEXTLABEL) as UILabel
        label.text = (data.allValues[indexPath.section] as NSArray).objectAtIndex(indexPath.row) as? String
        
      //  var imagenumber = cell.viewWithTag(TAG_CELL_IMAGELABEL) as UIImage
      //  imagenumber.
        return cell as UITableViewCell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        return data.allKeys[section] as String
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data.allValues[section] as NSArray).count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        println("\((data.allValues[indexPath.section] as NSArray).objectAtIndex(indexPath.row)) Clicked")
    }

}
