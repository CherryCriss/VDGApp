import Foundation
import SystemConfiguration
class Reachability {
    var hostname: String?
    var isRunning = false
    var isReachableOnWWAN: Bool
    var reachability: SCNetworkReachability?
    var reachabilityFlags = SCNetworkReachabilityFlags()
    let reachabilitySerialQueue = DispatchQueue(label: "ReachabilityQueue")
    init?(hostname: String) throws {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, hostname) else {
            throw Network.Error.failedToCreateWith(hostname)
        }
        self.reachability = reachability
        self.hostname = hostname
        isReachableOnWWAN = true
    }
    init?() throws {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }}) else {
                throw Network.Error.failedToInitializeWith(zeroAddress)
        }
        self.reachability = reachability
        isReachableOnWWAN = true
    }
    var status: Network.Status {
        return  !isConnectedToNetwork ? .unreachable :
                isReachableViaWiFi    ? .wifi :
                isRunningOnDevice     ? .wwan : .unreachable
    }
    var isRunningOnDevice: Bool = {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return false
        #else
            return true
        #endif
    }()
    deinit { stop() }
}
extension Reachability {
    func start() throws {
        guard let reachability = reachability, !isRunning else { return }
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged<Reachability>.passUnretained(self).toOpaque()
        guard SCNetworkReachabilitySetCallback(reachability, callout, &context) else { stop()
            throw Network.Error.failedToSetCallout
        }
        guard SCNetworkReachabilitySetDispatchQueue(reachability, reachabilitySerialQueue) else { stop()
            throw Network.Error.failedToSetDispatchQueue
        }
        reachabilitySerialQueue.async { self.flagsChanged() }
        isRunning = true
    }
    func stop() {
        defer { isRunning = false }
        guard let reachability = reachability else { return }
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        self.reachability = nil
    }
    var isConnectedToNetwork: Bool {
        return isReachable &&
               !isConnectionRequiredAndTransientConnection &&
               !(isRunningOnDevice && isWWAN && !isReachableOnWWAN)
    }
    var isReachableViaWiFi: Bool {
        return isReachable && isRunningOnDevice && !isWWAN
    }
    var flags: SCNetworkReachabilityFlags? {
        guard let reachability = reachability else { return nil }
        var flags = SCNetworkReachabilityFlags()
        return withUnsafeMutablePointer(to: &flags) {
            SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0))
            } ? flags : nil
    }
    func flagsChanged() {
        guard let flags = flags, flags != reachabilityFlags else { return }
        reachabilityFlags = flags
        NotificationCenter.default.post(name: .flagsChanged, object: self)
    }
    var transientConnection: Bool { return flags?.contains(.transientConnection) == true }
    var isReachable: Bool { return flags?.contains(.reachable) == true }
    var connectionRequired: Bool { return flags?.contains(.connectionRequired) == true }
    var connectionOnTraffic: Bool { return flags?.contains(.connectionOnTraffic) == true }
    var interventionRequired: Bool { return flags?.contains(.interventionRequired) == true }
    var connectionOnDemand: Bool { return flags?.contains(.connectionOnDemand) == true }
    var isLocalAddress: Bool { return flags?.contains(.isLocalAddress) == true }
    var isDirect: Bool { return flags?.contains(.isDirect) == true }
    var isWWAN: Bool { return flags?.contains(.isWWAN) == true }
    var isConnectionRequiredAndTransientConnection: Bool {
        return (flags?.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]) == true
    }
}
func callout(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    guard let info = info else { return }
    DispatchQueue.main.async {
        Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue().flagsChanged()
    }
}
extension Notification.Name {
    static let flagsChanged = Notification.Name("FlagsChanged")
}
struct Network {
    static var reachability: Reachability?
    enum Status: String, CustomStringConvertible {
        case unreachable, wifi, wwan
        var description: String { return rawValue }
    }
    enum Error: Swift.Error {
        case failedToSetCallout
        case failedToSetDispatchQueue
        case failedToCreateWith(String)
        case failedToInitializeWith(sockaddr_in)
    }
}
