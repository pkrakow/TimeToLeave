//
//  LocationTableViewCell.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 1/27/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//

import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell, MKMapViewDelegate {
    
    // MARK: Porperties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // mapview setup to show user location
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.scrollEnabled = false
        mapView.zoomEnabled = false
        //mapView.userInteractionEnabled = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
