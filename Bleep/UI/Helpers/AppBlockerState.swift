import Foundation

class AppBlockerState: ObservableObject {
    @Published var isBlocking: Bool = AppBlockerManager.shared.isBlockingActive()

    init() {
        NotificationCenter.default.addObserver(forName: .blockingStatusChanged, object: nil, queue: .main) { _ in
            self.isBlocking = AppBlockerManager.shared.isBlockingActive()
        }
    }
}
