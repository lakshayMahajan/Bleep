import Foundation
import CoreNFC

class NFCReader: NSObject, NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?

    func beginScan() {
        guard NFCTagReaderSession.readingAvailable else {
            print("NFC reading not available on this device")
            return
        }

        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your iPhone near an NFC tag to toggle app blocking."
        session?.begin()
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC session active")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("NFC session invalidated: \(error.localizedDescription)")
        self.session = nil
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        session.alertMessage = "Tag detected! Toggling app blocking..."
        AppBlockerManager.shared.toggleBlocking()
        session.invalidate()
        self.session = nil
    }
}
