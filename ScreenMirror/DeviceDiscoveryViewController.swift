import UIKit
import CocoaUPnP

class DeviceDiscoveryViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let addPhotoButton = UIButton(type: .system)
    private var devices: [UPPMediaRendererDevice] = []
    private let discovery = UPPDiscovery.sharedInstance()
    private var selectedIndexPath: IndexPath?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        discovery.addBrowserObserver(self)
        discovery.startBrowsing(forServices: "ssdp:all")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        discovery.removeBrowserObserver(self)
        discovery.stopBrowsingForServices()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "DLNA Devices"
        view.backgroundColor = .white
        
        // TableView
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        // Activity Indicator
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        // Add Photo Button
        addPhotoButton.setTitle("Выбрать фото", for: .normal)
        addPhotoButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        addPhotoButton.isHidden = true
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addPhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func openImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image", "public.movie"]
        present(picker, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension DeviceDiscoveryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addPhotoButton.isHidden = devices.isEmpty
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = devices[indexPath.row].friendlyName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        openImagePicker()
    }
}

// MARK: - UPPDiscoveryDelegate
extension DeviceDiscoveryViewController: UPPDiscoveryDelegate {
    func discovery(_ discovery: UPPDiscovery, didFind device: UPPBasicDevice) {
        guard let renderer = device as? UPPMediaRendererDevice else { return }
        
        DispatchQueue.main.async {
            if !self.devices.contains(where: { $0.udn == renderer.udn }) {
                self.devices.append(renderer)
                self.tableView.reloadData()
            }
        }
    }
    
    func discovery(_ discovery: UPPDiscovery, didRemove device: UPPBasicDevice) {
        DispatchQueue.main.async {
            self.devices.removeAll { $0.udn == device.udn }
            self.tableView.reloadData()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension DeviceDiscoveryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let indexPath = selectedIndexPath else { return }
        let device = devices[indexPath.row]
        
        if let image = info[.originalImage] as? UIImage {
            DLNAContentManager.shared.sendImage(image, to: device) { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                }
            }
        } else if let mediaURL = info[.mediaURL] as? URL {
            DLNAContentManager.shared.sendMedia(mediaURL, to: device) { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
