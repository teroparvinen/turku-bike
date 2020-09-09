//
// An interface for fetching and parsing data from the remote API.
// The errors handled are malformed URLs (should never trigger because the URL is hardcoded) and failures to fetch and/or parse data.
//

import UIKit
import Combine

class BikeRackRequest {
	
	enum RequestError: Error {
		case invalidUrl
		case apiError(systemError: Error)
		case parseError(systemError: Error)
		
		// Provide a user description for display on the UI
		var userDescription: String {
			switch self {
			case .apiError:
				return NSLocalizedString("Could not retrieve data", comment: "Error message")
			case .parseError:
				return NSLocalizedString("Received invalid data", comment: "Error message")
			default:
				// Fallback for errors not caused by external conditions
				return NSLocalizedString("Internal configuration error", comment: "Error message")
			}
		}
	}
	
	static let remoteUrlString = "https://data.foli.fi/citybike"
	
	static func fetch() -> AnyPublisher<Data, RequestError> {
		// Switch comments on the following two lines to debug JSON parse errors using the bundled citybike.json file
//		if let url = Bundle.main.url(forResource: "citybike", withExtension: "json") {
		if let url = URL(string: BikeRackRequest.remoteUrlString) {
			let urlRequest = URLRequest(url: url)
			return URLSession.DataTaskPublisher(request: urlRequest, session: .shared)
				.mapError { RequestError.apiError(systemError: $0) }
				.map { $0.data }
				.eraseToAnyPublisher()
		} else {
			return Fail(error: RequestError.invalidUrl)
				.eraseToAnyPublisher()
		}
	}
	
	static func fetchAndParse() -> AnyPublisher<RemoteResponse, RequestError> {
		fetch()
			.decode(type: RemoteResponse.self, decoder: JSONDecoder())
			.mapError { $0 as? RequestError ?? RequestError.parseError(systemError: $0) }
			.eraseToAnyPublisher()
	}
	
}
