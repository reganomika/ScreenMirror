import Foundation
import CocoaUPnP

enum ScreenMirrorSettingType {
    case mirrorTo
    case autoRotate
    case quality
    case sound
    
    var title: String {
        switch self {
        case .mirrorTo: return "Mirror to".localized
        case .autoRotate: return "Auto-rotate".localized
        case .quality: return "Quality".localized
        case .sound: return "Sound".localized
        }
    }
    
    var imageName: String {
        switch self {
        case .mirrorTo: return "mirrorTo"
        case .autoRotate: return "autoRotate"
        case .quality: return "quality"
        case .sound: return "sound"
        }
    }
}

enum MirrorToType: Int, CaseIterable {
    case tv
    case pc
    case others
    
    var title: String {
        switch self {
        case .tv: "TV".localized
        case .pc: "PC/Tablet".localized
        case .others: "Others".localized
        }
    }
}

enum ScreenMirrorSelectionType {
    case quality
    case mirrorTo
    
    var values: [String] {
        switch self {
        case .quality: QualityType.allCases.map({ $0.title })
        case .mirrorTo: MirrorToType.allCases.map({ $0.title })
        }
    }
    
    var title: String {
        switch self {
        case .quality:
            return "Quality".localized
        case .mirrorTo:
            return "Mirror to".localized
        }
    }
}

enum QualityType: Int, CaseIterable {
    case low
    case medium
    case high
    
    var title: String {
        switch self {
        case .low: "Low".localized
        case .medium: "Medium".localized
        case .high: "High".localized
        }
    }
}

enum ScreenMirrorCellType {
    case toggle(type: ScreenMirrorSettingType, value: Bool)
    case value(type: ScreenMirrorSettingType, value: String)
}

final class ScreenMirrorViewModel: NSObject {
    
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
    
    func configureCells() {
        cells.removeAll()
        cells.append(.value(type: .mirrorTo, value: mirrorToType.title))
        cells.append(.toggle(type: .autoRotate, value: isAutoRotate))
        cells.append(.value(type: .quality, value: qualityType.title))
        cells.append(.toggle(type: .sound, value: isSoundOn))
        onUpdate?()
    }
}
