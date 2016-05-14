//: Playground - noun: a place where people can play
// https://cocoapods.org/pods/Gloss

import UIKit
import MapKit

import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

DataManager.getTopAppsDataFromItunesWithSuccess { (data) -> Void in
    var json: [String: AnyObject]!

    // 1: deserialize the data using NSJSONSerialization
    do {
        json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject]
    } catch {
        print(error)
        XCPlaygroundPage.currentPage.finishExecution()
    }
    
    // 2: Initialize an instance of TopApps by feeding the JSON data into it's constructor
    guard let topApps = TopApps(json: json) else {
        print("Error initializing object")
        XCPlaygroundPage.currentPage.finishExecution()
    }
    
    // 3: Get the #1 app by simply getting the first entry of the feed
    guard let firstItem = topApps.feed?.entries?.first else {
        print("No such item")
        XCPlaygroundPage.currentPage.finishExecution()
    }
    
    // 4: Print the app to the console
    print(firstItem)
    
    
    
    XCPlaygroundPage.currentPage.finishExecution()
    
}


class jsonTestClass: Glossy {
    
    var ownerId: Int?
    var userName: String?
    var jsonBundle: JSON?
    
    init?(ownerId: Int?, userName: String?) {
        self.ownerId = ownerId
        self.userName = userName
        jsonBundle = self.toJSON()
    }
    
    required init?(json: JSON) {
        self.ownerId = "id" <~~ json
        self.userName = "login" <~~ json
        jsonBundle = json
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.ownerId,
            "login" ~~> self.userName
            ])
    }
    
    
}



let testObject1 = jsonTestClass(ownerId: 123, userName: "someGuy")
let jsonOne = testObject1?.toJSON()
let testObject2 = jsonTestClass(json: jsonOne!)
testObject2?.ownerId = 321
let jsonTwo = testObject2?.toJSON()
 
