import Foundation
import ManagedSettings
import FamilyControls
import DeviceActivity

extension Notification.Name {
    static let blockingStatusChanged = Notification.Name("blockingStatusChanged")
}

class AppBlockerManager: NSObject {
    static let shared = AppBlockerManager()
    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared
    private let isBlockingKey = "IsBlocking"

    private var isBlocking = false

    override private init() {
        super.init()
        isBlocking = UserDefaults.standard.bool(forKey: isBlockingKey)
        if isBlocking {
            startBlocking()
        }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                DispatchQueue.main.async { completion(true) }
            } catch {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    func startBlocking() {
        isBlocking = true
        UserDefaults.standard.set(true, forKey: isBlockingKey)
        NotificationCenter.default.post(name: .blockingStatusChanged, object: nil)
    }

    func stopBlocking() {
        isBlocking = false
        UserDefaults.standard.set(false, forKey: isBlockingKey)
        NotificationCenter.default.post(name: .blockingStatusChanged, object: nil)
    }

    func toggleBlocking() {
        isBlocking ? stopBlocking() : startBlocking()
    }

    func isBlockingActive() -> Bool {
        return isBlocking
    }
}
