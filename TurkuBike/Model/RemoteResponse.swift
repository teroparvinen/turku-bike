//
// The main JSON response received from the server. The primary data used is the list of racks available.
//

import Foundation

struct RemoteResponse: Decodable {
	
	enum CodingKeys: String, CodingKey {
		case racks
		case generated
		case lastUpdate = "lastupdate"
	}
	
	let racks: [String: Rack]
	
	let generated: Int
	let lastUpdate: Int
	
}
