//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

DataManager.getTopAppsDataFromFileWithSuccess { (data) -> Void in
  // TODO: Process data
  XCPlaygroundPage.currentPage.finishExecution()
}


// Native Swift JSON parsing

typealias Payload = [String: AnyObject]

DataManager.getTopAppsDataFromFileWithSuccess { (data) -> Void in
    
    var json: Payload!
    
    // 1: deserialize the data using NSJSONSerialization
    do {
        json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Payload
    } catch {
        print(error)
        XCPlaygroundPage.currentPage.finishExecution()
    }
    
    // 2: check each and every subscript value in the JSON object to make sure that it is not nil
    guard let feed = json["feed"] as? Payload,
        let apps = feed["entry"] as? [AnyObject],
        let app = apps.first as? Payload
        else { XCPlaygroundPage.currentPage.finishExecution() }
    
    guard let container = app["im:name"] as? Payload,
        let name = container["label"] as? String
        else { XCPlaygroundPage.currentPage.finishExecution() }
    
    guard let id = app["id"] as? Payload,
        let link = id["label"] as? String
        else { XCPlaygroundPage.currentPage.finishExecution() }
    
    // 3: If you made it through the nil checks, initialize the app with the data from the JSON response
    let entry = App(name: name, link: link)
    print(entry)
    
    XCPlaygroundPage.currentPage.finishExecution()
    
}

