import Foundation

public struct TopApps: Decodable {
    
    // 1: Define your model’s properties
    public let feed: Feed?
    
    // 2: Make sure TopApps conforms to the Decodable protocol by implementing the custom initializer
    public init?(json: JSON) {
        feed = "feed" <~~ json
    }
    
}
