//: Playground - noun: a place where people can play

import UIKit

let date = NSDate()

var formatter =  NSDateFormatter()
formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
let defaultTimeZoneStr = formatter.stringFromDate(date)

formatter.timeZone = NSTimeZone(abbreviation: "UTC")
let utcTimeZoneStr = formatter.stringFromDate(date)

formatter.timeZone = NSTimeZone.localTimeZone()
let localTimeZoneStr = formatter.stringFromDate(date)


