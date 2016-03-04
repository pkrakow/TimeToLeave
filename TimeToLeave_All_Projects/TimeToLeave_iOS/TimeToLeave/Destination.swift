//
//  Destination.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 1/18/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//


import CoreLocation
import MapKit

class Destination: CLLocationManager, MKMapViewDelegate, NSCoding {
    
    // MARK: Properties
    var destinationMapItem: MKMapItem?
    var arrivalTime: NSDate
    var arrivalDays: [Bool]
    var weeklyTrip: Bool

    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("destinations")
    
    
    // MARK: Types
    struct PropertyKey {

        static let destinationMapItemKey = "destinationMapItem"
        static let arrivalTimeKey = "arrivalTime"
        static let arrivalDaysKey = "arrivalDays"
        static let weeklyTripKey = "weeklyTrip"

    }
    
    // MARK: Initialization
    
    // Initializer for quickly creating a destination with an MKMapItem
    init?(destinationMapItem: MKMapItem, arrivalTime: NSDate) {
        
        // Initialize properties
        self.destinationMapItem = destinationMapItem
        self.arrivalTime = arrivalTime
        self.arrivalDays = [false, false, false, false, false, false, false]
        self.weeklyTrip = false
        
        super.init()
        
    }
    
    // Initializer for loading a stored destination
    init?(destinationMapItem: MKMapItem, arrivalTime: NSDate, arrivalDays: [Bool], weeklyTrip: Bool) {
        
        
        // Initialize properties
        self.destinationMapItem = destinationMapItem
        self.arrivalTime = arrivalTime
        self.arrivalDays = arrivalDays
        self.weeklyTrip = weeklyTrip

        super.init()
    }

    
    // MARK: CLLocationManagerDelegates
    func destinationViewControllerLocationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedAlways {
            // do stuff when location services authorized
            
        } else {
            // do stuff when location services denied
        }
    }
    
    // didFailWithError Delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if error.code == CLError.Denied.rawValue {
            manager.stopUpdatingLocation()
            print("Location Denied")
        }
    }
    
    

    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder){

        aCoder.encodeObject(arrivalDays, forKey: PropertyKey.arrivalDaysKey)
        aCoder.encodeObject(dateToString(arrivalTime), forKey: PropertyKey.arrivalTimeKey)
        aCoder.encodeBool(weeklyTrip, forKey: PropertyKey.weeklyTripKey)
        aCoder.encodeObject(destinationMapItem, forKey: PropertyKey.destinationMapItemKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {


        let arrivalDays = aDecoder.decodeObjectForKey(PropertyKey.arrivalDaysKey) as! [Bool]
        let weeklyTrip = aDecoder.decodeBoolForKey(PropertyKey.weeklyTripKey)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let arrivalTime = dateFormatter.dateFromString(aDecoder.decodeObjectForKey(PropertyKey.arrivalTimeKey) as! String)
        
        let destinationMapItem = aDecoder.decodeObjectForKey(PropertyKey.destinationMapItemKey) as! MKMapItem

        // Must call designated initilizer.
        self.init(destinationMapItem: destinationMapItem, arrivalTime: arrivalTime!, arrivalDays: arrivalDays, weeklyTrip: weeklyTrip)
    
    }
    
    
    func dateToString(date: NSDate) -> String! {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.stringFromDate(date)
    }
    

    
}
