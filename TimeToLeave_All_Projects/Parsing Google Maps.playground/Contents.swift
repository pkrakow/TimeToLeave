//: Playground - noun: a place where people can play

import UIKit
import Foundation
import XCPlayground



XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


public struct DistanceMatrix: Decodable {
    
    // 1: Define your model’s properties
    public let destination_addresses: [String]?
    public let origin_addresses: [String]?
    public let rows: [Row]?
    public let status: String?
    
    public init?(json: JSON) {
        self.destination_addresses = "destination_addresses" <~~ json
        self.origin_addresses = "origin_addresses" <~~ json
        self.rows = "rows" <~~ json
        self.status = "status" <~~ json
    }
    
}

public struct Row: Decodable {
    public let trips: [Trip]?
    
    public init?(json: JSON) {
        self.trips = "elements" <~~ json
    }
}


public struct Trip: Decodable {
    public let distance: Distance?
    public let duration: Duration?
    public let status: String?

    
    public init?(json: JSON) {
        self.distance = "distance" <~~ json
        self.duration = "duration" <~~ json
        self.status = "status" <~~ json
    }
    
}

public struct Distance: Decodable {
    
    // 1: Define your model’s properties
    public let text: String?
    public let value: String?
    
    


    
    public init?(json: JSON) {
        
        self.text = "text" <~~ json
        self.value = "value" <~~ json
    }
    
}

public struct Duration: Decodable {
    
    // 1: Define your model’s properties
    public let text: String?
    public let value: String?
    
 
    
    public init?(json: JSON) {
        
        text = "text" <~~ json
        value = "value" <~~ json
    }
    
}


func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
    let session = NSURLSession.sharedSession()
    
    let loadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
        if let responseError = error {
            completion(data: nil, error: responseError)
        } else if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode != 200 {
                let statusError = NSError(domain:"com.quackdonk", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                completion(data: nil, error: statusError)
            } else {
                completion(data: data, error: nil)
            }
        }
    }

    loadDataTask.resume()
}


func getDirectionsFromFileWithSuccess(success: ((data: NSData) -> Void)) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        let filePath = NSBundle.mainBundle().pathForResource("destination", ofType:"json")
        let data = try! NSData(contentsOfFile:filePath!,
            options: NSDataReadingOptions.DataReadingUncached)
        success(data: data)
    })
}



func getDirectionsWithSuccess(success: ((data: NSData!) -> Void)) {
    //1
    let googleMapsURL = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=2043+Mezes+Avenue+Belmont+CA+94002&destinations=701+North+First+Street+Sunnyvale+CA+94089&mode=driving&language=en-US&units=imperial"
    
    loadDataFromURL(NSURL(string: googleMapsURL)!, completion:{(data, error) -> Void in
        //2
        if let data = data {
            //3
            success(data: data)
        }
    })
}

getDirectionsFromFileWithSuccess { (data) -> Void in
//getDirectionsWithSuccess { (data) -> Void in
    var json: [String: AnyObject]!
    //print("data: ", data)

    // 1: deserialize the data using NSJSONSerialization
    do {
        //print("no error")
        json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [String: AnyObject]
    } catch {
        print(error)
        XCPlaygroundPage.currentPage.finishExecution()
    }
 
    // 2: Initialize an instance of DistanceMatrix by feeding the JSON data into it's constructor
    guard let thisDistanceMatrix = DistanceMatrix(json: json) else {
        print("Error initializing object")
        XCPlaygroundPage.currentPage.finishExecution()
    }
    
    // 3: Get the destination details
    guard let destination_address = thisDistanceMatrix.destination_addresses else {
        print("No destination_address")
        XCPlaygroundPage.currentPage.finishExecution()
    }
    
    guard let origin_address = thisDistanceMatrix.origin_addresses else {
        print("No origin_address")
        XCPlaygroundPage.currentPage.finishExecution()
    }
    

    guard let duration = thisDistanceMatrix.rows![0].trips![0].duration!.text else {
        print("No duration")
        XCPlaygroundPage.currentPage.finishExecution()
    }
    
    // 4: Print the destination to the console
    print("If you drive from", origin_address[0])
    print("to",destination_address[0])
    print("it will take", duration,"right now")

    var myStringArr = duration.componentsSeparatedByString(" ")
    print(myStringArr[0])
    var durationInt = Double(myStringArr[0])
    
    
    XCPlaygroundPage.currentPage.finishExecution()
 
}



func getTimeToLeave(arrivalTime: NSDate, travelTime: Double) -> NSDate {
    let timeToLeave: NSDate = arrivalTime.dateByAddingTimeInterval(-1*60*travelTime)
    return timeToLeave
}


let testTime = NSDate()
let testTimeToLeave: NSDate = getTimeToLeave(testTime, travelTime: 30)


