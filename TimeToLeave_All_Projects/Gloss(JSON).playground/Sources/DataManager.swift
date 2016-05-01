//
//  DataManager.swift
//  TopApps
//
//  Created by Attila on 2015. 11. 10..
//  Copyright © 2015. -. All rights reserved.
//

import Foundation
import MapKit


let TopAppURL = "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=25/json"

public class DataManager {
    
    public class func getTopAppsDataFromItunesWithSuccess(success: ((iTunesData: NSData!) -> Void)) {
        //1
        loadDataFromURL(NSURL(string: TopAppURL)!, completion:{(data, error) -> Void in
            //2
            if let data = data {
                //3
                success(iTunesData: data)
            }
        })
    }
  
    
    public class func getTimeToLeave(arrivalTime: NSDate) -> NSDate {
        
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
                let googleResult = Destination(json: json)
                print("googleResult: ", googleResult?.destination_addresses)


            }
        })
        
        return arrivalTime
    }
    
    
  public class func getTopAppsDataFromFileWithSuccess(success: ((data: NSData) -> Void)) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let filePath = NSBundle.mainBundle().pathForResource("topapps", ofType:"json")
      let data = try! NSData(contentsOfFile:filePath!,
        options: NSDataReadingOptions.DataReadingUncached)
      success(data: data)
    })
  }
  
  public class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
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
  
}


