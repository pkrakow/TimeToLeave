//
//  Destination.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 1/18/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//
//
//  Note: Use the Amazon Command Line Interface create-table command to create the Destinations DynamoDB Table
//
//  aws dynamodb create-table --table-name ttlTempTable5 --attribute-definitions AttributeName=uniqueDestinationID,AttributeType=S AttributeName=uniqueUserID,AttributeType=S AttributeName=jsonDestination,AttributeType=M --key-schema AttributeName=uniqueDestinationID,KeyType=HASH AttributeName=uniqueUserID,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5





//import CoreLocation
import MapKit
import Contacts
import AWSCore
import AWSDynamoDB
import Gloss


//class Destination: CLLocationManager, MKMapViewDelegate, AWSDynamoDBObjectModel, AWSDynamoDBModeling {
class Destination: AWSDynamoDBObjectModel, MKMapViewDelegate, AWSDynamoDBModeling, Glossy {
    
    // MARK: Properties
    var uniqueDestinationID:String?
    var uniqueUserID:String?
    var uniqueDeviceID:String?
    
    var destinationMapItem: MKMapItem
    var arrivalTime: NSDate
    var arrivalDays: [Bool]
    var weeklyTrip: Bool
    
    var jsonDestination: JSON?
 

 
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
        //self.uniqueUserID = AmazonClientManager.sharedInstance.credentialsProvider?.getIdentityId().result as? String
        self.uniqueDeviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        self.destinationMapItem = destinationMapItem
        self.arrivalTime = arrivalTime
        self.arrivalDays = [false, false, false, false, false, false, false]
        self.weeklyTrip = false
        
        super.init()

        self.jsonDestination = self.toJSON()
        //print("jsonDestination: ", self.jsonDestination)
        
    }
    
    // Initializer for creating a destination from a JSON object
    required init?(json: JSON) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        self.uniqueDestinationID = "uniqueDestinationID" <~~ json
        self.uniqueUserID = "uniqueUserID" <~~ json
        self.uniqueDeviceID = "uniqueDeviceID" <~~ json
        
        self.destinationMapItem = ("destinationMapItem" <~~ json)!
        self.arrivalTime = Decoder.decodeDate("arrivalTime", dateFormatter: dateFormatter)(json)!
        self.arrivalDays = ("arrivalDays" <~~ json)!
        self.weeklyTrip = ("weeklyTrip" <~~ json)!
        
        self.jsonDestination = json
        
        super.init()
        
    }
    
    // Initializer for loading a stored destination from NSArchive
    init?(uniqueDestinationID: String, uniqueUserID: String, uniqueDeviceID: String,  destinationMapItem: MKMapItem, arrivalTime: NSDate, arrivalDays: [Bool], weeklyTrip: Bool){
        
        // Initialize properties
        self.uniqueDestinationID = uniqueDestinationID
        self.uniqueUserID = uniqueUserID
        self.uniqueDeviceID = uniqueDeviceID
        
        self.destinationMapItem = destinationMapItem
        self.arrivalTime = arrivalTime
        self.arrivalDays = arrivalDays
        self.weeklyTrip = weeklyTrip

        super.init()
        
        self.jsonDestination = self.toJSON()        

    }
    
    func getTimeToLeave(arrivalTime: NSDate, destinationMapItem: MKMapItem) -> NSDate {
        
        let googleMapsURL = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=2043+Mezes+Avenue+Belmont+CA+94002&destinations=701+North+First+Street+Sunnyvale+CA+94089&mode=driving&language=en-US&units=imperial&key=AIzaSyAmFk8PdN-erkkgeg0PReI4DvWXUX0Mfmo"
        
        loadDataFromURL(NSURL(string: googleMapsURL)!, completion:{(data, error) -> Void in
            
            if let data = data {
                
                
                var json: [String: AnyObject]!
                
                // 1: deserialize the data using NSJSONSerialization
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject]
                } catch {
                    print(error)
                    
                }
                let googleResult = json as JSON
                print("googleResult: ", googleResult)
                let testExtraction = "destination_addresses" <~~ json
                
                
            }
        })
        
        return arrivalTime
    }
    
    func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
            let session = NSURLSession.sharedSession()
            
            let loadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
                if let responseError = error {
                    completion(data: nil, error: responseError)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        let statusError = NSError(domain:"com.raywenderlich", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                        completion(data: nil, error: statusError)
                    } else {
                        completion(data: data, error: nil)
                    }
                }
            }
            
            loadDataTask.resume()
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
    
    // MARK: JSON Functions
    
    func toJSON() -> JSON? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return jsonify([
            "uniqueDestinationID" ~~> self.uniqueDestinationID,
            "uniqueUserID" ~~> self.uniqueUserID,
            "uniqueDeviceID" ~~> self.uniqueDeviceID,
            Encoder.encodeDate("arrivalTime", dateFormatter: dateFormatter)(self.arrivalTime),
            "arrivalDays" ~~> self.arrivalDays,
            "weeklyTrip" ~~> self.weeklyTrip,
        
            // AWSURLRequestSerialization.m doesn't like MKMapItems, so pack up all of the important fields in json
            "destinationMapItem.name" ~~> self.destinationMapItem.name,
            "destinationMapItem.isCurrentLocation" ~~> self.destinationMapItem.isCurrentLocation,
            "destinationMapItem.phoneNumber" ~~> self.destinationMapItem.phoneNumber,
            "destinationMapItem.timeZone" ~~> self.destinationMapItem.timeZone,
            "destinationMapItem.url" ~~> self.destinationMapItem.url,
            
            "destinationMapItem.placemark.name" ~~> self.destinationMapItem.placemark.name,
            "destinationMapItem.placemark.countryCode" ~~> self.destinationMapItem.placemark.countryCode,
            "destinationMapItem.placemark.locality" ~~> self.destinationMapItem.placemark.locality,
            "destinationMapItem.placemark.administrativeArea" ~~> self.destinationMapItem.placemark.administrativeArea,
            "destinationMapItem.placemark.coordinate.latitude" ~~> self.destinationMapItem.placemark.coordinate.latitude,
            "destinationMapItem.placemark.coordinate.longitude" ~~> self.destinationMapItem.placemark.coordinate.latitude,
            "destinationMapItem.placemark.timeZone" ~~> self.destinationMapItem.placemark.timeZone
            ])
    }
    

 
    // MARK: NSCoding
    override func encodeWithCoder(aCoder: NSCoder){
        
        aCoder.encodeObject(uniqueDestinationID, forKey: PropertyKey.uniqueDestinationIDKey)
        aCoder.encodeObject(uniqueUserID, forKey: PropertyKey.uniqueUserIDKey)
        aCoder.encodeObject(uniqueDeviceID, forKey: PropertyKey.uniqueDeviceIDKey)
   
        aCoder.encodeObject(destinationMapItem.placemark, forKey: PropertyKey.destinationMapItemPlacemarkKey)
        aCoder.encodeObject(dateToString(arrivalTime), forKey: PropertyKey.arrivalTimeKey)
        aCoder.encodeObject(arrivalDays, forKey: PropertyKey.arrivalDaysKey)
        aCoder.encodeBool(weeklyTrip, forKey: PropertyKey.weeklyTripKey)
        
        // Not needed for NSCoding, but forces an update of jsonDestination anytime the Destination is archived
        self.jsonDestination = self.toJSON()

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

        //let jsonDestination = aDecoder.decodeObjectForKey("jsonDestinationKey") as! JSON
        //self.init(json: jsonDestination)

            
        // Must call designated initilizer.
        self.init(uniqueDestinationID: uniqueDestinationID, uniqueUserID: uniqueUserID, uniqueDeviceID: uniqueDeviceID, destinationMapItem: destinationMapItem, arrivalTime: arrivalTime!, arrivalDays: arrivalDays, weeklyTrip: weeklyTrip)
    
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
        return ["destinationMapItem", "arrivalTime", "arrivalDays", "weeklyTrip", "syncClient", "DocumentsDirectory", "ArchiveURL", "PropertyKey"]
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


