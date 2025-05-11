//
//import WebRTC
//
//struct ICECandidate {
//
//	// MARK: - Properties
//
//    var sdp: String
//    var sdpMLineIndex: Int32
//    var sdpMid: String?
//
//    var webRtcCompitable: RTCIceCandidate {
//        RTCIceCandidate(
//			sdp: sdp,
//			sdpMLineIndex: sdpMLineIndex,
//			sdpMid: sdpMid
//		)
//    }
//
//	// MARK: - Public methods
//
//    static func fromRtcCandidate(
//		_ candidate: RTCIceCandidate
//	) -> ICECandidate {
//		ICECandidate(
//			sdp: candidate.sdp,
//			sdpMLineIndex: candidate.sdpMLineIndex,
//			sdpMid: candidate.sdpMid
//		)
//    }
//
//}
//
//// MARK: - Codable
//
//extension ICECandidate: Codable {
//
//	enum CodingKeys: String, CodingKey {
//		case sdp, sdpMid, sdpMLineIndex
//	}
//
//}
