//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"



var targetArrivalTime: NSDate
targetArrivalTime = NSDate()


var testCalendar: NSCalendar


// http://www.brianjcoleman.com/tutorial-nsdate-in-swift/

let date = NSDate();
// "Apr 1, 2015, 8:53 AM" <-- local without seconds

var formatter = NSDateFormatter();
formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
let defaultTimeZoneStr = formatter.stringFromDate(date);
// "2015-04-01 08:52:00 -0400" <-- same date, local, but with seconds
formatter.timeZone = NSTimeZone(abbreviation: "UTC");
let utcTimeZoneStr = formatter.stringFromDate(date);
// "2015-04-01 12:52:00 +0000" <-- same date, now in UTC

// Paul's code - takes targetArrivalTime (which holds today's date) and spits out the numerical day of the week
formatter.dateFormat = "yyyy-MM-dd"
let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
let myComponents = myCalendar.components(.Weekday, fromDate: targetArrivalTime)
let weekDay = myComponents.weekday


// Example function to extract the day of the week from a string
func getDayOfWeek(today:String)->Int? {
    
    let formatter  = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    if let todayDate = formatter.dateFromString(today) {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay
    } else {
        return nil
    }
}

if let weekday = getDayOfWeek("2014-08-27") {
    print(weekday)
} else {
    print("bad input")
}


 var arrivalDays: [Bool]

arrivalDays = [true, false, true]
print(arrivalDays)
arrivalDays.last
arrivalDays.removeLast()
arrivalDays
arrivalDays[0]
arrivalDays[1]
arrivalDays[1] = true
arrivalDays


// Messing around with class inheritance
class Vehicle {
    var currentSpeed = 0.0
    var description: String {
        return "traveling at \(currentSpeed) miles per hour"
    }
    func makeNoise() {
        // do nothing - an arbitrary vehicle doesn't necessarily make a noise
    }
}

let someVehicle = Vehicle()

print("Vehicle: \(someVehicle.description)")


class Bicycle: Vehicle {
    var hasBasket = false
}

let bicycle = Bicycle()
bicycle.hasBasket = true

bicycle.currentSpeed = 15.0

print("Bicycle: \(bicycle.description)")



import CoreLocation

class Destination: CLLocationManager {
    
    // MARK: Properties
    var name: String
    var longitude: CLLocationDegrees
    var lattitude: CLLocationDegrees
    var arrivalDays: [Bool]
    var arrivalTime: NSDate
    var recurringTrip: Bool
    var destinationLocation: CLLocation
    
    
    // MARK: Initialization
    init?(name: String, longitude: CLLocationDegrees, latitude: CLLocationDegrees, arrivalTime: NSDate) {
        
        // Initialize stored properties
        self.name = name
        self.longitude = longitude
        self.lattitude = latitude
        self.arrivalDays = [false, false, false, false, false, false, false]
        self.arrivalTime = arrivalTime
        self.recurringTrip = false
        
        self.destinationLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        super.init()
        
        // Logic to have the initialization fail if the name is empty
        
        if name.isEmpty {
            return nil
        }
        
    }
    
}

let newDate = NSDate()
let newLongitude = CLLocationDegrees("+37.33233141")
let newLattitude = CLLocationDegrees("-122.03121860")
let newDestination = Destination(name: "testName", longitude: newLongitude!, latitude: newLattitude!, arrivalTime: newDate)
newDestination!.name
newDestination!.lattitude
newDestination!.destinationLocation
newDestination!.arrivalTime




// Tests for pulling variables from MKLocalSearch
import MapKit
var mapView: MKMapView!
var matchingLocations: [MKMapItem] = [MKMapItem]()

let request = MKLocalSearchRequest()
request.naturalLanguageQuery = "Restaurants"
//request.region = mapView.region

let search = MKLocalSearch(request: request)
search.startWithCompletionHandler { response, error in
    guard let response = response else {
        print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
        return
    }

    for item in response.mapItems {
        // Display the received items
        for item in response.mapItems {
            matchingLocations.append(item as MKMapItem)
            print(item.name)
        }

    }
}


print(matchingLocations.count)

// Seeking Closure
// a closure that has no parameters and return a String
var hello: () -> (String) = {
    return "Hello!"
}

hello() // Hello!
print(hello())


// a closure that take one Int and return an Int
var double: (Int) -> (Int) = { x in
    return 2 * x
}

double(2) // 4

// you can pass closures in your code, for example to other variables
var alsoDouble = double

alsoDouble(3) // 6




// Messing around with class construction

class simpleInputClass {
    init (name: String) {
        print(name)
    }
}

var testInstantiation = simpleInputClass(name: "this test")




// messing around with NSDate()
var arrivalTime = NSDate()

// NSTimeInterval is a double that measures time in seconds
var addTime = NSTimeInterval(60*60)



let dateFormatter = NSDateFormatter()
dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
let strDate = dateFormatter.stringFromDate(arrivalTime)
let testDate = dateFormatter.dateFromString("Feb 21, 2016, 6:00 AM")
let really = dateFormatter.stringFromDate(testDate!)


var newTime = arrivalTime.dateByAddingTimeInterval(addTime)

// Test code to throw away
print(strDate)



let calendar = NSCalendar.currentCalendar()
let day = NSCalendar.currentCalendar().component(.Weekday, fromDate: date)
let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: arrivalTime)
let minute = NSCalendar.currentCalendar().component(.Minute, fromDate: arrivalTime)
let timeHolder = [hour, minute]

let anotherTime = calendar.dateBySettingHour(3, minute: 00, second: 00, ofDate: arrivalTime, options: NSCalendarOptions(rawValue: 0))

arrivalDays = [false, false, false, false, false, false, false]
arrivalDays[1] = true
print(arrivalDays)

for (index, day) in arrivalDays.enumerate() {
    print(index, day)
}


class GettingClassy: CLLocationManager, NSCoding {
    var name1: String
    var name2: String
    
    override init() {
        name1 = "cat"
        name2 = name1
        super.init()
    }
    
    init(name1: String, input2: String) {
        self.name1 = name1
        name2 = input2
        super.init()
    }
    
    init(input1: String, input2: String) {
        name1 = input1
        name2 = input2
        super.init()
        
    }
    
    func bark() {
        print("oh yeah: ", name1, " ", name2)
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name1, forKey: "name1")
        aCoder.encodeObject(name2, forKey: "name2")
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        let name1 = aDecoder.decodeObjectForKey("name1") as! String
        let name2 = aDecoder.decodeObjectForKey("name2") as! String
        self.init(input1: name1, input2: name2)
    }
}

let dog = GettingClassy()
dog.bark()

let mediumDog = GettingClassy(name1: "benjo", input2: "boo")
mediumDog.bark()

let bigDog = GettingClassy(input1: "cow", input2: "pig")
bigDog.bark()



