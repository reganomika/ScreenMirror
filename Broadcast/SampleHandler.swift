
import ReplayKit
import Swifter

class SampleHandler: RPBroadcastSampleHandler {

    // MARK: - Properties

    private let rtcClient = RTCStreamer(appGroup: Config.groupId)

    // MARK: - Public methods
    
    override func broadcastFinished() {
        rtcClient.stopBroadcasting()
    }

    override func processSampleBuffer(
        _ sampleBuffer: CMSampleBuffer,
        with sampleBufferType: RPSampleBufferType
    ) {
        guard case RPSampleBufferType.video = sampleBufferType else {
            return
        }

        rtcClient.processSampleBuffer(sampleBuffer, sampleType: sampleBufferType)
    }

}
