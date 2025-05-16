
import Telegraph
import ReplayKit
import Photos
import UIKit

class ServerManager: NSObject {

    // MARK: - Properties

    private var server: Server?
    private var fileURL: URL?

    static let shared = ServerManager()
    private let extensionUserDefaults = UserDefaults(suiteName: Config.groupId)

    // MARK: - Public methods

    func startServer() {
        guard server == nil else { return }
        server = Server()

        server?.route(.GET, "data") { [weak self] request in
            guard let self else {
                return HTTPResponse(.internalServerError, body: "Ошибка сервера.".data(using: .utf8)!)
            }

            if let filePath = fileURL?.path {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                    let headers = HTTPHeaders(
                        uniqueKeysWithValues: [
                            ("Cache-Control", "no-cache, no-store, must-revalidate"),
                            ("Pragma", "no-cache"),
                            ("Expires", "0")
                        ]
                    )
                    return HTTPResponse(.ok, headers: headers, body: data)
                } catch {
                    return HTTPResponse(.internalServerError, body: "Ошибка загрузки файла.".data(using: .utf8)!)
                }
            } else {
                return HTTPResponse(.notFound, body: "Контент не найден.".data(using: .utf8)!)
            }
        }

        try? server?.start(port: 9090)
        server?.route(.GET, "status") { _ in
            HTTPResponse(
                .ok,
                body: "Server is running.".data(using: .utf8)!
            )
        }

        let address = "http://\(getIPAddress() ?? ""):8080"
        if let defaults = UserDefaults(suiteName: Config.groupId) {
            extensionUserDefaults?.set(RTCStreamQuality.good.rawValue, forKey: RTCKey.qualityCoefficient.rawValue)
            extensionUserDefaults?.set(address, forKey: RTCKey.streamAddress.rawValue)
        } else {
            fatalError()
        }
    }

    /// Остановка сервера
    func stopServer() {
        guard let server = server else { return }
        server.stop()
        self.server = nil
    }

    func loadFile(_ fileURL: URL) -> URL? {
        self.fileURL = fileURL

        guard let ipAddress = getIPAddress() else {
            return nil
        }

        return URL(string: "http://\(ipAddress):9090/data")
    }

    // MARK: - Private methods

    /// Получение IP-адреса устройства.
    func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6),
                   let name = String(cString: interface.ifa_name, encoding: .utf8),
                   name == "en0" {
                    var addr = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &addr,
                        socklen_t(addr.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    )
                    address = String(cString: addr)
                }
            }
            freeifaddrs(ifaddr)
        }

        return address
    }

}
