import Foundation
import Utilities

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
