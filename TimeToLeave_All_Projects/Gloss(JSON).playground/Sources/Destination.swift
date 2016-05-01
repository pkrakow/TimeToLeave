import Foundation

public struct Destination: Decodable {
    
    // 1: Define your model’s properties
    public let destination_addresses: String?
    
    // 2: Make sure TopApps conforms to the Decodable protocol by implementing the custom initializer
    public init?(json: JSON) {
        print("json: ", json)
        destination_addresses = "destination_addresses" <~~ json
        print("destination_addresses: ", destination_addresses)
    }
    
}
