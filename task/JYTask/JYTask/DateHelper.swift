//
//  File.swift
//  WorkTest
//
//  Created by wxqdev on 14-10-21.
//  Copyright (c) 2014年 wxqdev. All rights reserved.
//

import Foundation

extension NSDate {
    
    func formatted(format:String) -> String {
        let df = NSDateFormatter()
        df.dateFormat = format
        return df.stringFromDate(self)
    }
       
    func add(days count:Int) -> NSDate {
        let comp = self.components()
        comp.day += count
        return NSDate.fromComponents(comp)
    }
    
    func add(months count:Int) -> NSDate {
        let comp = self.components()
        comp.month += count
        return NSDate.fromComponents(comp)
    }
    
    
    func components() -> NSDateComponents {
        let cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        return cal!.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitWeekday, fromDate: self);
    }
    
    class func fromComponents(components:NSDateComponents) -> NSDate {
        let cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        //cal.timeZone = NSTimeZone(abbreviation: "GMT")
        return cal!.dateFromComponents(components)!
    }
    
    class func fromComponents(day:Int, month:Int, year:Int) -> NSDate {
        let cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        //cal.timeZone = NSTimeZone(abbreviation: "GMT")
        
        var components = NSDate().components()
        
        components.day = day
        components.month = month
        components.year = year
        
        return cal!.dateFromComponents(components)!
        
    }
}