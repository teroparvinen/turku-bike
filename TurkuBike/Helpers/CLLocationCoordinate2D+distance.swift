//
// A convenience extension to CLLocationCoordinate2D to calculate the distance between two points.
//

import CoreLocation

public extension CLLocationCoordinate2D {
	
	func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
		let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return from.distance(from: to)
	}
	
}
