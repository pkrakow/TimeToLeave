//
//  LocationTableViewController.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 2/3/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var locationSearchBar: UISearchBar!

    
    // MARK: Properties
    var destinationSearchBarText = ""
    
    // Variables for managing search locations
    var searchLocation: CLLocationCoordinate2D?
    var matchingLocations: [MKMapItem] = [MKMapItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the search bar delegate
        locationSearchBar.delegate = self
        
        // Store the initial text as a placeholder that shows up when the user clears the search box
        locationSearchBar.placeholder = locationSearchBar.text
        
        // Load the text from the DestionationViewController segue
        locationSearchBar.text = destinationSearchBarText
        
        // Search for a location from the locationSearchBar.text
        self.performSearch()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // Keep this set to 1 - all locations will be in one section
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return the number of rows
        //print("numberOfRowsInSection matchingLocations.count = ", matchingLocations.count)
        return matchingLocations.count

    }
    
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    
        // Location table view cells are reused and should be dequeued using a cell identifier
        
        let cellIdentifier = "LocationTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LocationTableViewCell
        
        // Setup the cell with the correct location
        initializeCell(cell, indexPath: indexPath)
    
        return cell
    }


    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Fetch the location that is associated with the cell
        //let matchingLocation = self.matchingLocations[indexPath.row]
        
        //print("Selection Worked: ", matchingLocation.name)
    }
 
    


    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

 
    
    // MARK: Search Bar Delegates
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        // Clear the search bar as soon as the user engages with it
        locationSearchBar.text = ""
        
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // Run a search when the user clicks the search button
        self.performSearch()
        
    }
    
    
    func performSearch() {
        
        // Clear out the matchingLocations array before running search
        self.matchingLocations.removeAll()
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = locationSearchBar.text
        // request.region = cell.mapView.region
        let search = MKLocalSearch(request: request)
        
        // Perform this search
        search.startWithCompletionHandler({(response: MKLocalSearchResponse?, error: NSError?) in
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
                
                
            } else {
                print("Matches found")
                
                for item in response!.mapItems {
                    
                    self.matchingLocations.append(item as MKMapItem)
                }
            }
            
            // After the search is complete, load the TableView with the search results
            self.tableView.reloadData()
            
        })
    }
    
    func initializeCell(cell: LocationTableViewCell, indexPath: NSIndexPath) {
        
        
        // Fetch the appropriate location for the data source layout
        let matchingLocation = self.matchingLocations[indexPath.row]
        
        // Name the cell
        var cellLabel = matchingLocation.name
        if let city = matchingLocation.placemark.locality,
            let state = matchingLocation.placemark.administrativeArea {
                cellLabel?.appendContentsOf(": \(city), \(state)")
        }
        cell.nameLabel.text = cellLabel
        
        // Center the cell.mapView on the search location and add an annotation
        cell.mapView.removeAnnotations(cell.mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = matchingLocation.placemark.coordinate
        annotation.title = matchingLocation.placemark.title
        if let city = matchingLocation.placemark.locality,
            let state = matchingLocation.placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
        }
        cell.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(matchingLocation.placemark.coordinate, span)
        cell.mapView.setRegion(region, animated: false)

    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "LocationToDestination" {

            if let destination = segue.destinationViewController as? DestinationViewController {

                if let selectedLocationCell = sender as? LocationTableViewCell {

                    let indexPath = tableView.indexPathForCell(selectedLocationCell)!
                    destination.inputLocation = self.matchingLocations[indexPath.row]

                }
            }
        }
    }
    
    
    
    
    
    
}
