//
//  googleDistanceMatrix.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 5/4/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//

import Foundation
import Gloss

public struct googleDistanceMatrix: Decodable {
    
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

