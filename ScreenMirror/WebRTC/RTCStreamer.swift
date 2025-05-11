
import Foundation
import WebRTC
import Swifter
import ReplayKit

public class RTCStreamer: NSObject {

	// MARK: - Properties

	private lazy var videoProducer = peerConnectionFactory.videoSource()
	private lazy var audioProducer = peerConnectionFactory.audioSource(with: mediaOptions)
	private lazy var videoTrack = peerConnectionFactory.videoTrack(with: videoProducer, trackId: "videoStream")
	private lazy var audioTrack = peerConnectionFactory.audioTrack(with: audioProducer, trackId: "audioStream")
	private lazy var videoCapturer = RTCVideoCapturer(delegate: videoProducer)

	private var defaults: UserDefaults?
	private var iceCandidates: [RTCResponse] = []
	private var peerConnection: RTCPeerConnection?
	private var connectionKey: String?
	private var videoSender: RTCRtpSender?
	private var audioSender: RTCRtpSender?
	private var serverPort: Int?
	private var rotateFlag: Bool?

	private let configuration = RTCConfiguration()
	private let server = HttpServer()
	private let queue = DispatchQueue(label: "RTCQueue", qos: .background)
	private let mediaOptions: RTCMediaConstraints = {
		return RTCMediaConstraints(
			mandatoryConstraints: ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"],
			optionalConstraints: nil
		)
	}()

	private let peerConnectionFactory: RTCPeerConnectionFactory = {
		RTCInitializeSSL()
		let encoderFactory = RTCDefaultVideoEncoderFactory()
		let decoderFactory = RTCDefaultVideoDecoderFactory()
		return RTCPeerConnectionFactory(
			encoderFactory: encoderFactory,
			decoderFactory: decoderFactory
		)
	}()

	// MARK: - Initialization

	init(appGroup: String) {
		super.init()

		defaults = UserDefaults(suiteName: appGroup)
		configureCapturing()
		configureServer()
		initializeConnection()
		generateOffer()
	}

	// MARK: - Public Methods

	public func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, sampleType: RPSampleBufferType) {
		guard let isRotationEnabled = rotateFlag else { return }

		switch sampleType {
		case .video:
			guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
			let rtcPixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
			var imageOrientation: CGImagePropertyOrientation?

			if let orientationAttachment = CMGetAttachment(
				sampleBuffer,
				key: RPVideoSampleOrientationKey as CFString,
				attachmentModeOut: nil
			) as? NSNumber {
				imageOrientation = isRotationEnabled
					? CGImagePropertyOrientation(rawValue: orientationAttachment.uint32Value)
					: nil
			}

			let timestampNs = Int64(
				CMTimeGetSeconds(
					CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
				) * 1_000_000_000
			)

			let rtcVideoFrame = RTCVideoFrame(
				buffer: rtcPixelBuffer,
				rotation: .fromCGImageOrientation(imageOrientation) ?? ._0,
				timeStampNs: timestampNs
			)

			videoProducer.capturer(videoCapturer, didCapture: rtcVideoFrame)

		default: break
		}
	}

	func stopBroadcasting() {
		defaults?.setValue("-", forKey: RTCKey.streamAddress.rawValue)
		defaults?.synchronize()
	}

}

// MARK: - Private Methods

extension RTCStreamer {

	private func initializeConnection() {
		configuration.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
		peerConnection = peerConnectionFactory.peerConnection(
			with: configuration,
			constraints: mediaOptions,
			delegate: nil
		)
		videoTrack.isEnabled = true
		videoSender = peerConnection?.add(
			videoTrack,
			streamIds: ["stream"]
		)
		generateOffer()
	}

	private func configureServer() {
		server["/stream"] = { [weak self] _ in
			guard let self else {
                return .notFound(nil)
			}

			return .ok(.text(self.streamHTML))
		}

		server["/webSocket"] = websocket(
			text: { [weak self] session, text in
				guard
					let data = text.data(using: .utf8),
					let response = try? JSONDecoder().decode(RTCResponse.self, from: data)
				else {
					return
				}
				self?.processResponse(response: response, session: session)
			},
			binary: { session, binary in
				session.writeBinary(binary)
			}
		)

		queue.async { [self] in
			try? server.start()
			serverPort = try? server.port()
			guard
				let port = serverPort,
				let address = getLocalAddress()
			else {
				return DispatchQueue.main.async { [weak self] in
					self?.defaults?.setValue("-", forKey: RTCKey.streamAddress.rawValue)
					self?.defaults?.synchronize()
				}
			}

			let streamURL = "\(address):\(port)/stream"

			DispatchQueue.main.async { [weak self] in
				self?.defaults?.setValue(streamURL, forKey: RTCKey.streamAddress.rawValue)
				self?.defaults?.synchronize()
			}
		}
	}

	private func processResponse(response: RTCResponse, session: WebSocketSession) {
		switch response.type {
		case "text":
			guard let connectionKey, response.content == "connected to socket" else {
				generateOffer()
				return
			}

			let offer = RTCResponse(type: "offer", sdp: connectionKey)

			do {
				let data = try JSONEncoder().encode(offer)
				let textToSend = String(data: data, encoding: .utf8) ?? ""
				session.writeText(textToSend)
			} catch { }
		case "candidate":
			guard
				let sdp = response.sdp,
				let lineIndex = response.sdpMLineIndex
			else {
				return
			}

			let candidate = ICECandidate(
				sdp: sdp,
				sdpMLineIndex: lineIndex,
				sdpMid: response.sdpMid
			)

			peerConnection?.add(candidate.webRtcCompitable)
			iceCandidates.forEach {
				do {
					let data = try JSONEncoder().encode($0)
					let textToSend = String(data: data, encoding: .utf8) ?? ""
					session.writeText(textToSend)
				} catch { }
			}
		case "answer":
			guard let sdp = response.sdp else { return }
			let description = RTCSessionDescription(type: .answer, sdp: sdp)
			peerConnection?.setRemoteDescription(description, completionHandler: { _ in })
		default:
			print("--> Unhandled response: ", response)
		}
	}

	private func generateOffer() {
		peerConnection?.offer(
			for: RTCMediaConstraints(
				mandatoryConstraints: nil,
				optionalConstraints: nil
			)
		) { [weak self] (sdp, error) in
			guard let self, let sdp = sdp else { return }

			self.connectionKey = sdp.sdp
			self.peerConnection?.setLocalDescription(sdp, completionHandler: { _ in })
		}
	}

	private func configureCapturing() {
		guard let defaults else {
			videoProducer.adaptOutputFormat(
				toWidth: Int32(UIScreen.main.bounds.width),
				height: Int32(UIScreen.main.bounds.height),
				fps: 30
			)
			rotateFlag = false
			return
		}

		rotateFlag = defaults.bool(forKey: RTCKey.rotationEnabled.rawValue)
		let screenWidth = Int32(UIScreen.main.bounds.width)
		let screenHeight = Int32(UIScreen.main.bounds.height)
		let qualityCoefficient = defaults.integer(forKey: RTCKey.qualityCoefficient.rawValue)
		let width = screenWidth / Int32(qualityCoefficient == 0 ? 1 : qualityCoefficient)
		let height = screenHeight / Int32(qualityCoefficient == 0 ? 1 : qualityCoefficient)
		videoProducer.adaptOutputFormat(toWidth: width, height: height, fps: 30)
	}

	private func getLocalAddress() -> String? {
		var address: String?
		var ifaddrs: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs(&ifaddrs) == 0 else { return nil }
		guard let firstAddr = ifaddrs else { return nil }
		for ifptr in Swift.sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
			let interface = ifptr.pointee
			let family = interface.ifa_addr.pointee.sa_family
			if family == UInt8(AF_INET) || family == UInt8(AF_INET6) {
				let name = String(cString: interface.ifa_name)
				if name == "en0" {
					var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
								&hostname, socklen_t(hostname.count),
								nil, socklen_t(0), NI_NUMERICHOST)
					address = String(cString: hostname)
				}
			}
		}
		freeifaddrs(ifaddrs)
		return address
	}

}

extension RTCVideoRotation {

    static func fromCGImageOrientation(_ rotation: CGImagePropertyOrientation?) -> Self? {
        switch rotation {
        case .down: ._180
        case .downMirrored: ._0
        case .left: ._90
        case .leftMirrored: ._270
        case .right: ._270
        case .rightMirrored: ._90
        case .up: ._0
        case .upMirrored: ._180
        case .none: ._0
        }
    }

}

// MARK: - Private Extensions

private extension RTCStreamer {

	var streamHTML: String {
		"""
		<html>
		<head>
			<title>Smart Cast</title>
			<script src="https://cdnjs.cloudflare.com/ajax/libs/screenfull.js/5.1.0/screenfull.js"></script>
			<script src="https://webrtc.github.io/adapter/adapter-latest.js"></script>
			<link rel="icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAAQAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAACXSURBVHicY2AgDKgAPAAGJ0F9XYAAAAAElFTkSuQmCC"/>
			<style>
				html, body {
					width: 100%;
					height: 100%;
					margin: 0;
					padding: 0;
					background-color: black;
					font-family: Arial, Helvetica, sans-serif;
				}
				#video, #image {
					position: fixed;
					top: 0;
					left: 0;
					width: 100%;
					height: 100%;
					object-fit: contain;
					pointer-events: none;
				}
				#hint {
					position: fixed;
					top: 30px;
					left: 30px;
					font-size: 1.25em;
					font-weight: 600;
					color: white;
					transition: opacity 0.25s;
				}
			</style>
		</head>
		<body>
			<div id="container" style="width:100%; height:100%">
				<video id="video" autoplay controls></video>
				<img id="image" src="/static">
				<span id="hint">Click to enter full screen mode and unmute</span>
			</div>
			<script>
				const webSocketPath = "webSocket"
				const host = window.location.hostname || 'localhost'
				const container = document.getElementById('container')
				const image = document.getElementById('image')
				const video = document.getElementById('video')
				const hint = document.getElementById('hint')
				let connected = false
				let connection = null
				let audioContext = new (window.AudioContext || window.webkitAudioContext)();
				let source = audioContext.createBufferSource();
				let destination = audioContext.destination;
		
				video.addEventListener('canplay', () => {
					console.log("video can play")
				})
		
				container.addEventListener('click', () => {
					unmuteVideo()
					hideHint()

					if (!screenfull.isEnabled) {
						return
					}
				   
					if (screenfull.isFullscreen) {
						screenfull.exit()
					} else {
						screenfull.request(container)
					}
				});

				window.onload = function () {
					reconnect()
					setTimeout(hideHint, 10000)
					setInterval(reconnect, 3000)
				}

				function unmuteVideo() {
					video.muted = false
				}

				function hideHint() {
					hint.style.opacity = 0
				}

				function reconnect() {
					if (connected) {
						return
					}

					if (!("WebSocket" in window)) {
						alert("Your browser doesn't support web sockets :(")
						return
					}

					let socket = new WebSocket("ws://" + host + ":\(serverPort ?? 0)/" + webSocketPath)

					socket.onopen = function() {
						connected = true
						hideHint()
					}

					socket.onclose = function() {
						connected = false
					}

					socket.onmessage = function (event) {
						let json = JSON.parse(event.data)
						switch (json.type) {
							case "offer":
								handleOffer(json)
								break
							case "candidate":
								handleCandidate(json)
								break
							default:
								console.log('unhandled message type: ', json.type)
						}
					}
				}

				function handleOffer(message) { }
				function handleCandidate(message) { }
			</script>
		</body>
		</html>
		"""
	}

}
