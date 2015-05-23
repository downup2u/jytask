//
//  KeyboardTableView.swift
//  JYTask
//
//  Created by wxqdev on 14-11-28.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

import UIKit

class KeyboardTableView: UITableView {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.superview?.touchesBegan(touches, withEvent: event)
        super.touchesBegan(touches, withEvent: event)
    }
}
