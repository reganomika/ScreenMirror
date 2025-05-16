import UIKit
import ReplayKit
import SnapKit

class BroadcastPickerView: UIView {
    
    // MARK: - Properties
    
    private let picker = RPSystemBroadcastPickerView(frame: .zero)
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPicker()
    }
    
    // MARK: - Setup
    
    private func setupPicker() {
        picker.preferredExtension = Config.extensionBundle
        picker.showsMicrophoneButton = true
        
        addSubview(picker)
        
        picker.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    // MARK: - Public Methods
    
    func startBroadcast() {
        if let button = picker.subviews.first(where: { $0 is UIButton }) as? UIButton {
            button.sendActions(for: .touchUpInside)
        }
    }
    
    func updatePreferredExtension(_ bundleIdentifier: String) {
        picker.preferredExtension = bundleIdentifier
    }
    
    func updateSize(_ size: CGSize) {
        picker.snp.updateConstraints { make in
            make.size.equalTo(size)
        }
    }
}
