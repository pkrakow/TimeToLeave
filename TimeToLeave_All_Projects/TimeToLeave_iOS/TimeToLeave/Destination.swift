//
//  Destination.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 1/18/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//
//


//import CoreLocation
import MapKit
import Contacts
import AWSCore
import AWSDynamoDB
import Gloss


class Destination: AWSDynamoDBObjectModel, MKMapViewDelegate, AWSDynamoDBModeling, Glossy {
    
    // MARK: Properties
    var uniqueDestinationID:String?
    var uniqueUserID:String?
    var uniqueDeviceID:String?
    
    var destinationMapItem: MKMapItem
    var arrivalTime: NSDate
    var departureTime: NSDate?
    var arrivalDays: [Bool]
    var weeklyTrip: Bool

    
    var jsonDestination: JSON?
 

 
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("destinations")
 
    
    // MARK: PropertyKey for archiving
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
        self.uniqueUserID = User.sharedInstance!.uniqueUserID
        self.uniqueDeviceID = User.sharedInstance!.uniqueDeviceID
        self.destinationMapItem = destinationMapItem
        self.arrivalTime = arrivalTime
        self.arrivalDays = [false, false, false, false, false, false, false]
        self.weeklyTrip = false
        
        super.init()
        updateDepartureTime()
        self.jsonDestination = self.toJSON()

        
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
        self.departureTime = Decoder.decodeDate("departureTime", dateFormatter: dateFormatter)(json)!
        self.arrivalDays = ("arrivalDays" <~~ json)!
        self.weeklyTrip = ("weeklyTrip" <~~ json)!
        
        self.jsonDestination = json
        
        super.init()
        
        // Remember to remove this line after AWS starts correcting departure times
        updateDepartureTime()
        
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
        updateDepartureTime()
        self.jsonDestination = self.toJSON()        

    }

    // MARK: Departure Time Functions
 
    func updateDepartureTime() {
        
        // Make the call to Google Maps to get travel time json
        getGoogleDistanceMatrixWithSuccess { (data) -> Void in
            var json: [String: AnyObject]!
            var travelTimeHoursDouble: Double?
            var travelTimeMinutesDouble: Double?
            
            // 1: deserialize the data using NSJSONSerialization
            do {
                
                json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [String: AnyObject]
            } catch {
                print(error)
                
            }
            
            // 2: Initialize an instance of DistanceMatrix by feeding the JSON data into it's constructor
            guard let thisDistanceMatrix = googleDistanceMatrix(json: json) else {
                print("Error initializing object")
                return
            }
            
            // Check to make sure Google returned a valid travel time
            if thisDistanceMatrix.status == "OK" {
                if thisDistanceMatrix.rows![0].trips![0].status == "OK" {
                    guard let travelTimeString = thisDistanceMatrix.rows![0].trips![0].duration!.text else {
                        print("No duration")
                        return
                    }
                    var travelTimeStringArray = travelTimeString.componentsSeparatedByString(" ")
                    if travelTimeStringArray.count == 4 {
                        travelTimeHoursDouble = Double(travelTimeStringArray[0])
                        travelTimeMinutesDouble = Double(travelTimeStringArray[2])
                    } else {
                        travelTimeHoursDouble = 0
                        travelTimeMinutesDouble = Double(travelTimeStringArray[0])
                    }
                    self.departureTime = self.arrivalTime.dateByAddingTimeInterval(-60*60*travelTimeHoursDouble!-60*travelTimeMinutesDouble!)
                    print("arrivalTime = ", self.arrivalTime)
                    print("travelTime = ", travelTimeString)
                    print("departureTime = ", self.departureTime)
                } else {
                    print("Trip Status != OK")
                }
            } else {
                print("Distance Matrix Status != OK")
            }
        }
        
    }
    
    
    func getGoogleDistanceMatrixWithSuccess(success: ((data: NSData!) -> Void)) {
        
        guard let googleMapsURL = buildGoogleMapsURL(destinationMapItem) else {
            print("Unable to build googleMapsURL")
            return
        }
        
        loadDataFromURL(NSURL(string: googleMapsURL)!, completion:{(data, error) -> Void in
            
            if let data = data {
                //3
                success(data: data)
            }
        })
    }
    
    
 
    func buildGoogleMapsURL(destinationMapItem: MKMapItem) -> String? {
        
        var googleMapsURL: String?
        var origin: String?
        var destination: String?
        User.sharedInstance!.locationManager.requestLocation()

        

            
        // Check to make sure you have a location
        if (User.sharedInstance!.locationManager.location != nil){
            
            // Set the origin to the user's location
            origin = String(User.sharedInstance!.locationManager.location!.coordinate.latitude) + "," + String(User.sharedInstance!.locationManager.location!.coordinate.longitude)
            
            // Set the destination to the destination (duh)
            destination = "&destinations=" + String(destinationMapItem.placemark.coordinate.latitude) + "," + String(destinationMapItem.placemark.coordinate.longitude)
            
            // mode options: driving; walking; bicycling; transit
            let mode: String = "&mode=driving"
            //let mode: String = "&mode=bicycling"
            
            
            googleMapsURL = "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
            googleMapsURL?.appendContentsOf(origin!)
            googleMapsURL?.appendContentsOf(destination!)
            googleMapsURL?.appendContentsOf(mode)
            googleMapsURL?.appendContentsOf("&language=en-US&units=imperial")
            
            
            print("googleMapsURL: ", googleMapsURL)
        } else {
            googleMapsURL = nil
        }
        
        return googleMapsURL

    }
    
    
    func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        
        let loadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain:"com.timetoleave", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        }
        
        loadDataTask.resume()
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
            Encoder.encodeDate("departureTime", dateFormatter: dateFormatter)(self.departureTime),
            "arrivalDays" ~~> self.arrivalDays,
            "weeklyTrip" ~~> self.weeklyTrip,
        
            // AWSURLRequestSerialization.m doesn't like MKMapItems, so pack up all of the important fields in json
            "destinationMapItem.name" ~~> self.destinationMapItem.name,
            "destinationMapItem.isCurrentLocation" ~~> self.destinationMapItem.isCurrentLocation,
            "destinationMapItem.phoneNumber" ~~> self.destinationMapItem.phoneNumber,
            //"destinationMapItem.timeZone" ~~> self.destinationMapItem.timeZone,
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
        return Constants.TimeToLeaveDynamoDBDestinationTableName
    }
    
    
    // if we define attribute it must be included when calling it in function testing...
    class func hashKeyAttribute() -> String! {
        return "uniqueUserID"
    }
    
    class func rangeKeyAttribute() -> String! {
        return "uniqueDestinationID"
    }
    
    
    class func ignoreAttributes() -> Array<AnyObject>! {
        return ["uniqueDeviceID", "destinationMapItem", "arrivalTime", "departureTime", "arrivalDays", "weeklyTrip", "syncClient", "DocumentsDirectory", "ArchiveURL", "PropertyKey"]
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


