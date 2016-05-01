//
//  DestinationViewController.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 1/17/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//


import UIKit
import CoreLocation
import MapKit
import Contacts


class DestinationViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var onceOrWeeklyControl: UISegmentedControl!
    @IBOutlet var arrivalDaysButtons: [UIButton]!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    
    // Variables for creating a destination
    var arrivalTime: NSDate?
    var inputLocation: MKMapItem?
    var thisDestination: Destination?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the mapView to show the user's location
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        
        
        // Check if a segue did not populate thisDestination
        if (thisDestination == nil) {
            
            // Set the minimum date to now
            arrivalTime = NSDate()
            datePicker.minimumDate = arrivalTime
            
            // Check if you have an inputLocation from the LocationTableViewController
            if (inputLocation != nil) {
                
                // Initialize the destination from the LocationTableViewController
                thisDestination = Destination(destinationMapItem: inputLocation!, arrivalTime: arrivalTime!)
                thisDestination?.arrivalDays[ getDay(arrivalTime!) - 1] = true
            } else {
                
                // Set thisDestination to the user's current location
                
                let addressDictionary = [String(CNPostalAddressStreetKey): "Current Location"]
                let placemark = MKPlacemark(coordinate: mapView.region.center, addressDictionary: addressDictionary)
                let mapItem = MKMapItem(placemark: placemark)
                thisDestination = Destination(destinationMapItem: mapItem, arrivalTime: arrivalTime!)

            }
        }
        
        // Set the destinationName
        var name = thisDestination?.destinationMapItem.name
        if let city = thisDestination?.destinationMapItem.placemark.locality,
            let state = thisDestination?.destinationMapItem.placemark.administrativeArea {
                name?.appendContentsOf(": \(city) \(state)")
        }
        destinationName.text = name
        
        // Center the mapView on thisDestination
        setupMap((thisDestination?.destinationMapItem)!)
        
        // Set the arrivalTime
        datePicker.date = (thisDestination?.arrivalTime)!
        
        // Set the onceOrWeekly control
        if(thisDestination!.weeklyTrip){
            onceOrWeeklyControl.selectedSegmentIndex = 1
        } else {
            onceOrWeeklyControl.selectedSegmentIndex = 0
        }
        
        // Set the right buttons for the days of the week you want to travel
        for (index, arrivalDayButton) in arrivalDaysButtons.enumerate() {
            //print("Button: ", arrivalDayButton)
            arrivalDayButton.selected = (thisDestination?.arrivalDays[index])!
        }
        
    }



    


    // MARK: Actions
    

    // Use the datePicker to select the time you want to arrive
    @IBAction func datePicker(sender: UIDatePicker) {
        // Set the arrivalTime variable to the date in the datePicker
        arrivalTime = datePicker.date
        
        // Update the destination.arrivalTime with the new arrivalTime
        thisDestination?.arrivalTime = arrivalTime!
        
        
    }
    
    @IBAction func onceOrWeeklyControl(sender: UISegmentedControl) {
        if (onceOrWeeklyControl.selectedSegmentIndex == 0) {
            thisDestination!.weeklyTrip = false
        } else {
            thisDestination!.weeklyTrip = true
        }
    }
    



    
    @IBAction func sundayButton(sender: UIButton) {
        invertButtonState(sender)
        thisDestination?.arrivalDays[0] = sender.selected
    }
    
    @IBAction func mondayButton(sender: UIButton) {
        invertButtonState(sender)
        thisDestination?.arrivalDays[1] = sender.selected
    }
    
    @IBAction func tuesdayButton(sender: UIButton) {
        invertButtonState(sender)
        thisDestination?.arrivalDays[2] = sender.selected
    }
    
    @IBAction func wednesdayButton(sender: UIButton) {
        invertButtonState(sender)
        thisDestination?.arrivalDays[3] = sender.selected
    }
    
    @IBAction func thursdayButton(sender: UIButton) {
        invertButtonState(sender)
        thisDestination?.arrivalDays[4] = sender.selected
    }
    
    @IBAction func fridayButton(sender: UIButton) {
        invertButtonState(sender)
        thisDestination?.arrivalDays[5] = sender.selected
    }
    
    
    @IBAction func saturdayButton(sender: UIButton) {
        invertButtonState(sender)
        thisDestination?.arrivalDays[6] = sender.selected
    }
    
    
    func invertButtonState(button: UIButton) {
        if (button.selected == true) {
            button.selected = false
        } else {
            button.selected = true
        }
    }
    
    
    
    
    
    // Returns the integer value of the weekday of a given date (Sunday == 1, etc.)
    func getDay(date: NSDate) -> Int {
        
        let day = NSCalendar.currentCalendar().component(.Weekday, fromDate: date)
    
        return day
    }

    
    // Setup the mapView for the destination
    func setupMap(location: MKMapItem) {
        // Add an annotation to the mapView for the location
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.placemark.coordinate
        annotation.title = location.placemark.title
        
        if let city = location.placemark.locality,
            let state = location.placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        
        // Center the mapView on the location
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(location.placemark.coordinate, span)
        mapView.setRegion(region, animated: false)
    }


}


