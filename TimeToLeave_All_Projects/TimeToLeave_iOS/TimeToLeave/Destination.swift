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


//class Destination: CLLocationManager, MKMapViewDelegate, AWSDynamoDBObjectModel, AWSDynamoDBModeling {
class Destination: AWSDynamoDBObjectModel, MKMapViewDelegate, AWSDynamoDBModeling {
    
    // MARK: Properties
    var uniqueDestinationID:String?
    var uniqueUserID:String?
    var uniqueDeviceID:String?
    
    var destinationMapItem: MKMapItem?
    var arrivalTime: NSDate
    var arrivalDays: [Bool]
    var weeklyTrip: Bool
 

 
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("destinations")
 
    
    // MARK: Types
    struct PropertyKey {

        static let uniqueDestinationIDKey = "uniqueDestinationID"
        static let uniqueUserIDKey = "uniqueUserID"
        static let uniqueDeviceIDKey = "uniqueDeviceID"
        
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
        self.uniqueDestinationID = NSUUID().UUIDString
        self.uniqueUserID = AmazonClientManager.sharedInstance.credentialsProvider?.logins["graph.facebook.com"] as? String
        self.uniqueDeviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        self.destinationMapItem = destinationMapItem
        self.arrivalTime = arrivalTime
        self.arrivalDays = [false, false, false, false, false, false, false]
        self.weeklyTrip = false
        
        super.init()
        
    }
    
    
    // Initializer for loading a stored destination
    init?(uniqueDestinationID: String, uniqueUserID: String, uniqueDeviceID: String,  destinationMapItem: MKMapItem, arrivalTime: NSDate, arrivalDays: [Bool], weeklyTrip: Bool){
    //init?(uniqueDestinationID: String, uniqueUserID: String, destinationMapItem: MKMapItem, arrivalTime: NSDate, arrivalDays: [Bool], weeklyTrip: Bool){
        
        // Initialize properties
        self.uniqueDestinationID = uniqueDestinationID
        self.uniqueUserID = uniqueUserID
        self.uniqueDeviceID = uniqueDeviceID
        
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
        
        aCoder.encodeObject(uniqueDestinationID, forKey: PropertyKey.uniqueDestinationIDKey)
        aCoder.encodeObject(uniqueUserID, forKey: PropertyKey.uniqueUserIDKey)
        aCoder.encodeObject(uniqueDeviceID, forKey: PropertyKey.uniqueDeviceIDKey)
   
        aCoder.encodeObject(destinationMapItem?.placemark, forKey: PropertyKey.destinationMapItemPlacemarkKey)
        aCoder.encodeObject(dateToString(arrivalTime), forKey: PropertyKey.arrivalTimeKey)
        aCoder.encodeObject(arrivalDays, forKey: PropertyKey.arrivalDaysKey)
        aCoder.encodeBool(weeklyTrip, forKey: PropertyKey.weeklyTripKey)


    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let uniqueDestinationID = aDecoder.decodeObjectForKey(PropertyKey.uniqueDestinationIDKey) as! String
        let uniqueUserID = aDecoder.decodeObjectForKey(PropertyKey.uniqueUserIDKey) as! String
        let uniqueDeviceID = aDecoder.decodeObjectForKey(PropertyKey.uniqueDeviceIDKey) as! String
 
        let arrivalDays = aDecoder.decodeObjectForKey(PropertyKey.arrivalDaysKey) as! [Bool]
        let weeklyTrip = aDecoder.decodeBoolForKey(PropertyKey.weeklyTripKey)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let arrivalTime = dateFormatter.dateFromString(aDecoder.decodeObjectForKey(PropertyKey.arrivalTimeKey) as! String)
        
        
        let destinationPlacemark = aDecoder.decodeObjectForKey(PropertyKey.destinationMapItemPlacemarkKey) as! MKPlacemark
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

 

            
        // Must call designated initilizer.
        self.init(uniqueDestinationID: uniqueDestinationID, uniqueUserID: uniqueUserID, uniqueDeviceID: uniqueDeviceID, destinationMapItem: destinationMapItem, arrivalTime: arrivalTime!, arrivalDays: arrivalDays, weeklyTrip: weeklyTrip)
        //self.init(uniqueDestinationID: uniqueDestinationID, uniqueUserID: uniqueUserID, destinationMapItem: destinationMapItem, arrivalTime: arrivalTime!, arrivalDays: arrivalDays, weeklyTrip: weeklyTrip)

    
    }
    
    
    func dateToString(date: NSDate) -> String! {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.stringFromDate(date)
    }
    
 
    
    // MARK: AWSDynamoDB
    
    
    class func dynamoDBTableName() -> String! {
        return Constants.TimeToLeaveDynamoDBTableName
    }
    
    
    // if we define attribute it must be included when calling it in function testing...
    class func hashKeyAttribute() -> String! {
        return "uniqueDestinationID"
    }
    
    class func rangeKeyAttribute() -> String! {
        return "uniqueUserID"
    }
    
    
    class func ignoreAttributes() -> Array<AnyObject>! {
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


