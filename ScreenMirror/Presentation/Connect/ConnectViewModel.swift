import RxSwift
import CocoaUPnP

final class ConnectViewModel: NSObject, UPPDiscoveryDelegate {
    // MARK: - Properties
    private(set) var devices: [UPPMediaRendererDevice] = [] {
        didSet {
            devicesDidChange?()
        }
    }
    
    var isNotFound = false
    
    var devicesDidChange: (() -> Void)?
    var showAlert: ((String, String) -> Void)?
    
    // MARK: - Public Methods
    func startDiscovery() {
        isNotFound = false
        devicesDidChange?()
        devices = UPPDiscovery.sharedInstance().availableDevices().compactMap({ $0 as? UPPMediaRendererDevice })
        UPPDiscovery.sharedInstance().addBrowserObserver(self)
        UPPDiscovery.sharedInstance().startBrowsing(forServices: "ssdp:all")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            
            if self.devices.isEmpty {
                self.stopDiscovery()
                self.isNotFound = true
                self.devicesDidChange?()
            }
        }
    }
    
    func stopDiscovery() {
        UPPDiscovery.sharedInstance().removeBrowserObserver(self)
        UPPDiscovery.sharedInstance().stopBrowsingForServices()
    }
    
    func didSelectDevice(at index: Int) {
        guard index >= 0 && index < devices.count else { return }
        let device = devices[index]
        DLNAContentManager.shared.currentDevice = device
        devicesDidChange?()
    }
    
    // MARK: - UPPDiscoveryDelegate
    func discovery(_ discovery: UPPDiscovery, didFind device: UPPBasicDevice) {
        guard let renderer = device as? UPPMediaRendererDevice else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.devices.contains(where: { $0.udn == renderer.udn }) {
                self.devices.append(renderer)
            }
        }
    }
    
    func discovery(_ discovery: UPPDiscovery, didRemove device: UPPBasicDevice) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.devices.removeAll { $0.udn == device.udn }
        }
    }
}
