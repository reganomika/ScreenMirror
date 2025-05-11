import CocoaUPnP
import GCDWebServer
import MobileCoreServices

class DLNAContentManager {
    static let shared = DLNAContentManager()
    
    private var webServer: GCDWebServer?
    private var tempFiles = [URL]()
    
    init() {
        setupWebServer()
    }
    
    deinit {
        cleanupTempFiles()
    }
    
    private func setupWebServer() {
        webServer = GCDWebServer()
        webServer?.addGETHandler(forBasePath: "/",
                               directoryPath: NSTemporaryDirectory(),
                               indexFilename: nil,
                               cacheAge: 0,
                               allowRangeRequests: true)
        webServer?.start(withPort: 8080, bonjourName: nil)
    }
    
    // MARK: - Public Methods
    
    func sendMedia(_ mediaURL: URL, to device: UPPMediaRendererDevice, completion: @escaping (Error?) -> Void) {
        let fileExtension = mediaURL.pathExtension.lowercased()
        let isVideo = ["mp4", "mov", "avi"].contains(fileExtension)
        
        prepareMediaForSending(mediaURL) { [weak self] result in
            switch result {
            case .success(let (_, serverURL)):
                let metadata = self?.createMetadata(for: serverURL.absoluteString, isVideo: isVideo)
                self?.sendContent(to: device, url: serverURL.absoluteString, metadata: metadata, completion: completion)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func sendImage(_ image: UIImage, to device: UPPMediaRendererDevice, completion: @escaping (Error?) -> Void) {
        prepareImageForSending(image) { [weak self] result in
            switch result {
            case .success(let (_, serverURL)):
                let metadata = self?.createMetadata(for: serverURL.absoluteString, isVideo: false)
                self?.sendContent(to: device, url: serverURL.absoluteString, metadata: metadata, completion: completion)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func prepareMediaForSending(_ mediaURL: URL, completion: @escaping (Result<(URL, URL), Error>) -> Void) {
        guard let serverURL = webServer?.serverURL else {
            completion(.failure(NSError(domain: "DLNA", code: -1, userInfo: [NSLocalizedDescriptionKey: "Web server not running"])))
            return
        }
        
        let fileName = "dlna_media_\(Int(Date().timeIntervalSince1970)).\(mediaURL.pathExtension)"
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: mediaURL.path) {
                try FileManager.default.copyItem(at: mediaURL, to: destinationURL)
                tempFiles.append(destinationURL)
                completion(.success((destinationURL, serverURL.appendingPathComponent(fileName))))
            } else {
                completion(.failure(NSError(domain: "DLNA", code: -2, userInfo: [NSLocalizedDescriptionKey: "Source file not found"])))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func prepareImageForSending(_ image: UIImage, completion: @escaping (Result<(URL, URL), Error>) -> Void) {
        guard let serverURL = webServer?.serverURL else {
            completion(.failure(NSError(domain: "DLNA", code: -1, userInfo: [NSLocalizedDescriptionKey: "Web server not running"])))
            return
        }
        
        let fileName = "dlna_image_\(Int(Date().timeIntervalSince1970)).jpg"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(NSError(domain: "DLNA", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
                return
            }
            
            do {
                try data.write(to: fileURL)
                self.tempFiles.append(fileURL)
                DispatchQueue.main.async {
                    completion(.success((fileURL, serverURL.appendingPathComponent(fileName))))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func createMetadata(for url: String, isVideo: Bool) -> String {
        if isVideo {
            return """
            <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/"
                      xmlns:dc="http://purl.org/dc/elements/1.1/"
                      xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">
                <item id="1" parentID="0" restricted="0">
                    <dc:title>Video from iPhone</dc:title>
                    <upnp:class>object.item.videoItem</upnp:class>
                    <res protocolInfo="http-get:*:video/mp4:DLNA.ORG_PN=AVC_MP4_HD;DLNA.ORG_OP=01">\(url)</res>
                </item>
            </DIDL-Lite>
            """
        } else {
            return """
            <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/"
                      xmlns:dc="http://purl.org/dc/elements/1.1/"
                      xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">
                <item id="1" parentID="0" restricted="0">
                    <dc:title>Image from iPhone</dc:title>
                    <upnp:class>object.item.imageItem.photo</upnp:class>
                    <res protocolInfo="http-get:*:image/jpeg:DLNA.ORG_PN=JPEG_TN;DLNA.ORG_OP=01">\(url)</res>
                </item>
            </DIDL-Lite>
            """
        }
    }
    
    private func sendContent(to device: UPPMediaRendererDevice,
                           url: String,
                           metadata: String?,
                           completion: @escaping (Error?) -> Void) {
        device.avTransportService()?.setAVTransportURI(url,
                                                     currentURIMetaData: metadata,
                                                     instanceID: "0") { success, error in
            if success {
                device.avTransportService()?.play(withInstanceID: "0", speed: "1") { playSuccess, playError in
                    completion(playSuccess ? nil : playError)
                }
            } else {
                completion(error)
            }
        }
    }
    
    private func cleanupTempFiles() {
        for fileURL in tempFiles {
            try? FileManager.default.removeItem(at: fileURL)
        }
        tempFiles.removeAll()
    }
}
