//
// A source for device location information, used through the singleton instance available as the `shared` property.
// Takes care of asking the user for permission and provides updates through a publisher.
//

import CoreLocation
import Combine

class LocationSource: NSObject, CLLocationManagerDelegate {
	static let shared = LocationSource()
	
	enum Failure: Error {
		case notAuthorized
		case locationDisabled
	}
	
	enum State {
		case uninitialized
		case requestingAuthorization
		case awaitingLocation
		case denied
		case hasLocation
		case stopped
	}
	
	var state: State = .uninitialized
	
	let locationManager = CLLocationManager()
	
	typealias LocationHandler = (CLLocationCoordinate2D?) -> ()
	
	var publisher = CurrentValueSubject<CLLocationCoordinate2D?, Failure>(nil)
	
	override private init() {
		super.init()
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			manager.startUpdatingLocation()
			state = .awaitingLocation
		} else {
			state = .denied
			publisher.send(completion: .failure(.notAuthorized))
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		if error._code == CLError.denied.rawValue {
			state = .denied
			publisher.send(completion: .failure(.notAuthorized))
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		state = .hasLocation
		let coordinates = locationManager.location!.coordinate
		publisher.send(coordinates)
	}
	
	func start() {
		if CLLocationManager.locationServicesEnabled() {
			if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
				state = .awaitingLocation
				locationManager.startUpdatingLocation()
			} else if CLLocationManager.authorizationStatus() == .notDetermined {
				state = .requestingAuthorization
				locationManager.requestWhenInUseAuthorization()
			}
		} else {
			publisher.send(completion: .failure(.locationDisabled))
		}
	}
	
	func stop() {
		state = .stopped
		locationManager.stopUpdatingLocation()
	}
}
