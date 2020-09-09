//
// A model object representing a single bike rack, the primary data model for the app.
// The information stored for each rack includes the id, name, location coordinate, the available bikes and the number of empty slots.
//

import Foundation
import CoreLocation

struct Rack: Decodable, Hashable {
	enum CodingKeys: String, CodingKey {
		case id
		case name
		
		case coordinateLongitude = "lon"
		case coordinateLatitude = "lat"
		
		case classicBikesAvailable = "bikes_avail_classic"
		case electricBikesAvailable = "bikes_avail_electric"
		case emptySlots = "slots_avail"
	}
	
	let id: String
	let name: String
	
	let coordinateLongitude: Double
	let coordinateLatitude: Double
	
	let classicBikesAvailable: Int
	let electricBikesAvailable: Int
	let emptySlots: Int
	
	var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: coordinateLatitude, longitude: coordinateLongitude)
	}
	
}
