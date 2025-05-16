import Foundation
import CocoaUPnP

final class ScreenMirrorViewModel {
    
    private let serverManager: ServerManager = .shared
    
    let broadcastPicker: BroadcastPickerView
    
    var qualityType: QualityType = .low
    var mirrorToType: MirrorToType = .tv
    var isAutoRotate: Bool = true
    var isSoundOn: Bool = false
    
    var cells: [ScreenMirrorCellType] = []
    
    var showAlert: ((String, String) -> Void)?
    
    var onUpdate: (() -> Void)?
    
    var device: UPPMediaRendererDevice? {
        DLNAContentManager.shared.currentDevice
    }
    
    private(set) var urlString: String
    
    init() {
        urlString = "http://\(serverManager.getIPAddress()!):8080/stream"
        print(urlString)
        broadcastPicker = BroadcastPickerView()
    }
    
    func startCast() {
        broadcastPicker.startBroadcast()
    }
    
    func configureCells() {
        cells.removeAll()
        cells.append(.value(type: .mirrorTo, value: mirrorToType.title))
        cells.append(.toggle(type: .autoRotate, value: isAutoRotate))
        cells.append(.value(type: .quality, value: qualityType.title))
        cells.append(.toggle(type: .sound, value: isSoundOn))
        onUpdate?()
    }
}
