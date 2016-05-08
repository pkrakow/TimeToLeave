//
//  User.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 5/7/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//

import Foundation
import CoreLocation

class User: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = User()
    
    // MARK: Properties
    var uniqueUserID:String?
    var locationManager: CLLocationManager!
    var regionRadius: CLLocationDistance = 1000
    
    // MARK: Initialization
    override init() {
        
        // Create a location manager object
        locationManager = CLLocationManager()
        
        super.init()
        
        // Set the location manager delegate
        locationManager.delegate = self
        
        // Request location authorization 
        //locationManager.requestAlwaysAuthorization()
        
        // Set location accuracy to Best for creating new destinations
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request the current location
        locationManager.requestLocation()
        
        // Enable background location monitoring
        self.startBackgroundLocationMonitoring()
        
    }
    
    // MARK: Functions
    func getUniqueUserID() {
        self.uniqueUserID = AmazonClientManager.sharedInstance.credentialsProvider?.logins["graph.facebook.com"] as? String
        //self.uniqueUserID = AmazonClientManager.sharedInstance.credentialsProvider?.getIdentityId().result as? String
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
        //print("Location: ", locations)
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

}