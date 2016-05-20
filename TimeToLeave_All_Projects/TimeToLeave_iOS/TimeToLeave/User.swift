//
//  User.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 5/7/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//

import Foundation
import CoreLocation
import AWSCore
import AWSDynamoDB
import Gloss


class User: AWSDynamoDBObjectModel, CLLocationManagerDelegate, AWSDynamoDBModeling, Glossy {
    static let sharedInstance = User()
    
    // MARK: Properties
    var uniqueUserID:String?
    var uniqueDeviceID:String?
    var locationManager: CLLocationManager
    let regionRadius: CLLocationDistance = 1000
    var jsonUser: JSON?

    // Initialize the AWS Dynamo DB Object Mapper
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("users")


    
    // MARK: Initialization
    override init?() {
        
        // Set the uniqueUserID (Delete after debugging)
        self.uniqueUserID = AmazonClientManager.sharedInstance.credentialsProvider?.logins["graph.facebook.com"] as? String
        
        // Set the uniqueDeviceID
        self.uniqueDeviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        // Create a location manager object
        locationManager = CLLocationManager()
        
        super.init()
        
        // Set the location manager delegate
        locationManager.delegate = self
        
        // Set location accuracy to Best for creating new destinations
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request the current location
        locationManager.requestLocation()
        
        // Enable background location monitoring
        self.startBackgroundLocationMonitoring()
        
        // Populate the JSON verion of the user
        self.jsonUser = self.toJSON()
        
    }
    
/*
    init?(uniqueUserID: String, uniqueDeviceID: String, locationManager: CLLocationManager) {
        
        // Initialize properties
        self.uniqueUserID = uniqueUserID
        self.uniqueDeviceID = uniqueDeviceID
        self.locationManager = locationManager
        
        super.init()
        
        self.jsonUser = self.toJSON()
    }
*/

    // Initializer for creating a user from a JSON object
    required convenience init?(json: JSON) {
        
        // Create a new user from scratch - results will be the same as restoring a copy
        self.init()
        
    }

    // Create a JSON version of the user object
    func toJSON() -> JSON? {
        
        return jsonify([
            "uniqueUserID" ~~> self.uniqueUserID,
            "uniqueDeviceID" ~~> self.uniqueDeviceID,
            "locationManager.location.coordinate.latitude" ~~> self.locationManager.location!.coordinate.latitude,
            "locationManager.location.coordinate.longitude" ~~> self.locationManager.location!.coordinate.longitude
            ])
        
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

    // didUpdateLocations Delegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // If the location gets updated, update the record that's stored in AWS DynamoDB
        //print("didUpdateLocations")
        self.jsonUser = self.toJSON()
        dynamoDBObjectMapper.save(self)

    }
    
    func startBackgroundLocationMonitoring() {
        
        // Create a location manager object
        locationManager = CLLocationManager()
        
        // Set the delegate
        locationManager.delegate = self
        
        // Request location authorization
        locationManager.requestAlwaysAuthorization()
        
        // Set an accuracy level.  The bigger the distance, the better the energy savings
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // Set a distance filter (in meters) - only needed for update method
        //locationManager.distanceFilter = 500
        
        // Enable automatic pausing
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // Specify that the app is tracking automotive navigation
        locationManager.activityType = CLActivityType.AutomotiveNavigation
        
        // Enable background location updates
        locationManager.allowsBackgroundLocationUpdates = true
        
        // Start location monitoring to track when user changes location
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    // MARK: PropertyKey for archiving
    struct PropertyKey {
        static let uniqueUserIDKey = "uniqueUserID"
        static let uniqueDeviceIDKey = "uniqueDeviceID"
        static let locationManagerKey = "locationManager"
    }
    
    // MARK: NSCoding
    override func encodeWithCoder(aCoder: NSCoder){
        
        aCoder.encodeObject(uniqueUserID, forKey: PropertyKey.uniqueUserIDKey)
        aCoder.encodeObject(uniqueDeviceID, forKey: PropertyKey.uniqueDeviceIDKey)
        aCoder.encodeObject(locationManager, forKey: PropertyKey.locationManagerKey)
        
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // Create a new user from scratch - results will be the same as restoring a copy
        self.init()
       
        
    }
    
    
    // MARK: AWSDynamoDB
    class func dynamoDBTableName() -> String! {
        return Constants.TimeToLeaveDynamoDBUserTableName
    }
    
    
    // if we define attribute it must be included when calling it in function testing...
    class func hashKeyAttribute() -> String! {
        return "uniqueUserID"
    }
    
    class func rangeKeyAttribute() -> String! {
        return "uniqueDeviceID"
    }
    
    
    class func ignoreAttributes() -> Array<AnyObject>! {

        return ["sharedInstance", "locationManager", "regionRadius", "dynamoDBObjectMapper"]

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