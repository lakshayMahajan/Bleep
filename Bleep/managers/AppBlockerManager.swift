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
    private let savedSelectionKey = "SavedFamilyActivitySelection"

    private var isBlocking = false
    var selection: FamilyActivitySelection = FamilyActivitySelection()

    override private init() {
        super.init()
        loadSelection()
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
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        isBlocking = true
        UserDefaults.standard.set(true, forKey: isBlockingKey)
        NotificationCenter.default.post(name: .blockingStatusChanged, object: nil)
    }

    func stopBlocking() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
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

    func updateSelection(_ newSelection: FamilyActivitySelection) {
        self.selection = newSelection
        saveSelection()
    }

    private func saveSelection() {
        do {
            let data = try JSONEncoder().encode(selection)
            UserDefaults.standard.set(data, forKey: savedSelectionKey)
        } catch {
            print("Failed to save selection: \(error)")
        }
    }

    private func loadSelection() {
        guard let data = UserDefaults.standard.data(forKey: savedSelectionKey) else { return }
        do {
            selection = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("Failed to load selection: \(error)")
        }
    }
}
