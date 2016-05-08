//
//  DestinationTableViewController.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 1/26/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSDynamoDB


class DestinationTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var destinationSearchBar: UISearchBar!
   
    
    // MARK: Properties
    var destinations = [Destination]()


    // Initialize the Cognito Sync client and dataset
    let syncClient = AWSCognito.defaultCognito()    
    
    // Initialize the AWS Dynamo DB Object Mapper
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the search bar delegate
        destinationSearchBar.delegate = self
        
        // Store the initial text as a placeholder that shows up when the user clears the search box
        destinationSearchBar.placeholder = destinationSearchBar.text
        
        // Use the edit button provided by the table view controller
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load any saved destinations
        if let savedDestinations = loadDestinations() {
            destinations += savedDestinations
        } else {
            // Put something here for cold start
            print("No saved destinations")
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Keep this set to 1 - all destinations will be in one section
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return destinations.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "DestinationTableViewCell"

        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DestinationTableViewCell
        
        // Fetche the appropriate destination for the data source layout
        let destination = destinations[indexPath.row]
        
        // Configure the cell here (add code after the cell design is refined)

        // Name the cell
        var cellLabel = destination.destinationMapItem.name
        if let city = destination.destinationMapItem.placemark.locality,
            let state = destination.destinationMapItem.placemark.administrativeArea {
                cellLabel?.appendContentsOf(": \(city), \(state)")
        }
        
        // Temp code for adding TTL to the table view cell
        if (destination.departureTime != nil) {
            let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: destination.departureTime!)
            let minute = NSCalendar.currentCalendar().component(.Minute, fromDate: destination.departureTime!)
            
            var TTL: String?
            if minute < 10 {
                TTL = "   " + String(hour) + ":0" + String(minute)
            } else {
                TTL = "   " + String(hour) + ":" + String(minute)
            }
            print("TTL = ", TTL)
            cellLabel?.appendContentsOf(TTL!)
        }
        
        cell.nameLabel.text = cellLabel

        return cell
    }
  

    // MARK: Search Bar Delegates
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        // Clear the search bar as soon as the user engages with it
        destinationSearchBar.text = ""
        
    }

    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // When the user finishes typing their search, send them to the LocationTableViewController
        performSegueWithIdentifier("SearchLocation", sender: self)

    }
    


    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete the destination from that row
            destinations.removeAtIndex(indexPath.row)
            
            // Update the saved copy of destinations to reflect the deletion
            saveDestinations()
            
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchLocation" {
            if let destination = segue.destinationViewController as? LocationTableViewController {
                
                // Pass the destinationSearchBar.text string to the LocationTableViewController
                destination.destinationSearchBarText = destinationSearchBar.text!
            }
        } else if segue.identifier == "ShowDetail" {
            let destinationDetailViewController = segue.destinationViewController as! DestinationViewController
            if let selectedDestinationCell = sender as? DestinationTableViewCell {
                // Get the cell that the user selected
                let indexPath = tableView.indexPathForCell(selectedDestinationCell)!
                let selectedDestination = destinations[indexPath.row]
                // Set the detail view to show the contents of that cell
                destinationDetailViewController.thisDestination = selectedDestination
                selectedDestination.updateDepartureTime()
            }
        }

    }
    
    // Unwind Segue
    @IBAction func unwindToDestinationList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? DestinationViewController, destination = sourceViewController.thisDestination {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
            
                // Update an existing Destination
                destinations[selectedIndexPath.row] = destination
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            
            } else {
                
                // Add a new Destination
                let newIndexPath = NSIndexPath(forRow: destinations.count, inSection: 0)
                destinations.append(destination)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)

            }
            
            // Update the saved copy of destinations
            saveDestinations()
        }
    }
    
    // MARK: Saving and Loading Destinations
    func saveDestinations(){
        
        // Save locally to the client via NSKeyedArchiver
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(destinations, toFile: Destination.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save destinations...")
        }
        
        // Save each destination to AWS DynamoDB
        for destination in destinations {
            
            dynamoDBObjectMapper.save(destination)

            
        }
        

    
    }
    
    func loadDestinations() -> [Destination]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Destination.ArchiveURL.path!) as? [Destination]
    }

}




