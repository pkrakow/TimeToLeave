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

//class User: NSObject, CLLocationManagerDelegate {
//class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
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
        
    }
    

    init?(uniqueUserID: String, uniqueDeviceID: String, locationManager: CLLocationManager) {
        
        // Initialize properties
        self.uniqueUserID = uniqueUserID
        self.uniqueDeviceID = uniqueDeviceID
        self.locationManager = locationManager
        
        super.init()
        
        self.jsonUser = self.toJSON()
    }
 

    // Initializer for creating a user from a JSON object
    required init?(json: JSON) {
        
        self.uniqueUserID = ("uniqueUserID" <~~ json)!
        self.uniqueDeviceID = ("uniqueDeviceID" <~~ json)!
        self.locationManager = ("locationManager" <~~ json)!
        self.jsonUser = json
        
        super.init()
        
    }
/*
    // MARK: Functions
    func getUniqueUserID() {
        
        // Set the uniqueUserID (Delete after debugging)
        //self.uniqueUserID = "Test_String_uniqueUserID"
        
        self.uniqueUserID = AmazonClientManager.sharedInstance.credentialsProvider?.logins["graph.facebook.com"] as? String
        //self.uniqueUserID = AmazonClientManager.sharedInstance.credentialsProvider?.getIdentityId().result as? String
        //print("self.uniqueUserID: ", self.uniqueUserID)
    }
*/
    // Create a JSON version of the user object
    func toJSON() -> JSON? {
        
        return jsonify([
            "uniqueUserID" ~~> self.uniqueUserID,
            "uniqueDeviceID" ~~> self.uniqueDeviceID,
            "locationManager" ~~> self.locationManager
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
        print("didUpdateLocations")
        self.jsonUser = self.toJSON()
        //dynamoDBObjectMapper.save(self)

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
        //static let locationManagerKey = "locationManager"
    }
    
    // MARK: NSCoding
    override func encodeWithCoder(aCoder: NSCoder){
        
        aCoder.encodeObject(uniqueUserID, forKey: PropertyKey.uniqueUserIDKey)
        aCoder.encodeObject(uniqueDeviceID, forKey: PropertyKey.uniqueDeviceIDKey)
       //aCoder.encodeObject(locationManager, forKey: PropertyKey.locationManagerKey)
        
        // Remember to add the self.toJSON code here later
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // Decode the archived variables for the class
        //let uniqueUserID = aDecoder.decodeObjectForKey(PropertyKey.uniqueUserIDKey) as! String
        //let uniqueDeviceID = aDecoder.decodeObjectForKey(PropertyKey.uniqueDeviceIDKey) as! String
        //let locationManager = aDecoder.decodeObjectForKey(PropertyKey.locationManagerKey) as! CLLocationManager
        
        // Initialize the class with those variables
        //self.init(uniqueUserID: uniqueUserID, uniqueDeviceID: uniqueDeviceID, locationManager: locationManager)
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

        return ["sharedInstance", "locationManager", "regionRadius", "dynamoDBObjectMapper", "jsonUser"]

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