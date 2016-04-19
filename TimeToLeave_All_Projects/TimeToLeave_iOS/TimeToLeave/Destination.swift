//
//  Destination.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 1/18/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//


//import CoreLocation
import MapKit
import Contacts
import AWSCore
import AWSDynamoDB

//class Destination: CLLocationManager, MKMapViewDelegate, NSCoding {
//class Destination: CLLocationManager, MKMapViewDelegate, NSCoding, AWSDynamoDBObjectModel, AWSDynamoDBModeling {
class Destination: AWSDynamoDBObjectModel, MKMapViewDelegate {
    
    // MARK: Properties
    var uniqueDeviceIdentifier = UIDevice.currentDevice().identifierForVendor!.UUIDString
    var destinationMapItem: MKMapItem?
    var arrivalTime: NSDate
    var arrivalDays: [Bool]
    var weeklyTrip: Bool
 
    
    // Initialize the Cognito Sync client and dataset
    //let syncClient = AWSCognito.defaultCognito()

 
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("destinations")
 
    
    // MARK: Types
    struct PropertyKey {

        static let destinationMapItemPlacemarkKey = "destinationMapItemPlacemark"
        static let destinationMapItemUrlKey = "destinationMapItemUrl"
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

/*
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
  */
    

 
    // MARK: NSCoding
    override func encodeWithCoder(aCoder: NSCoder){
   
        aCoder.encodeObject(destinationMapItem?.placemark, forKey: PropertyKey.destinationMapItemPlacemarkKey)
        aCoder.encodeObject(dateToString(arrivalTime), forKey: PropertyKey.arrivalTimeKey)
        aCoder.encodeObject(arrivalDays, forKey: PropertyKey.arrivalDaysKey)
        aCoder.encodeBool(weeklyTrip, forKey: PropertyKey.weeklyTripKey)


    }
    
    required convenience init?(coder aDecoder: NSCoder) {


        let arrivalDays = aDecoder.decodeObjectForKey(PropertyKey.arrivalDaysKey) as! [Bool]
        let weeklyTrip = aDecoder.decodeBoolForKey(PropertyKey.weeklyTripKey)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let arrivalTime = dateFormatter.dateFromString(aDecoder.decodeObjectForKey(PropertyKey.arrivalTimeKey) as! String)
        
        
        let destinationPlacemark = aDecoder.decodeObjectForKey(PropertyKey.destinationMapItemPlacemarkKey) as! MKPlacemark
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)


        // Must call designated initilizer.
        self.init(destinationMapItem: destinationMapItem, arrivalTime: arrivalTime!, arrivalDays: arrivalDays, weeklyTrip: weeklyTrip)
    
    }
    
    
    func dateToString(date: NSDate) -> String! {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.stringFromDate(date)
    }
    
 
    
    // MARK: AWSDynamoDB
    
    
    func dynamoDBTableName() -> String! {
        return Constants.TimeToLeaveDynamoDBTableName
    }
    
    
    // if we define attribute it must be included when calling it in function testing...
    func hashKeyAttribute() -> String! {
        return "uniqueDeviceIdentifier"
    }
    
    class func rangeKeyAttribute() -> String! {
        return nil
    }
    
    
    func ignoreAttributes() -> Array<AnyObject>! {
        //return nil
        return ["destinationMapItem", "arrivalTime", "arrivalDays", "weeklyTrip", "syncClient", "DocumentsDirectory","ArchiveURL","PropertyKey"]
    }
    
    //MARK: NSObjectProtocol hack
    //Fixes Does not conform to the NSObjectProtocol error
    
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    
    override func `self`() -> Self {
        return self
    }

    
}


