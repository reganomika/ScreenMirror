
import Foundation

struct RTCResponse: Equatable {

	// MARK: - Properties

    var type: String
    var content: String?
    var sdp: String?
    var sdpMid: String?
    var sdpMLineIndex: Int32?
    
}

// MARK: - Properties

extension RTCResponse: Codable {

	enum CodingKeys: String, CodingKey {
		case type, content, sdp, sdpMid, sdpMLineIndex
	}

}
