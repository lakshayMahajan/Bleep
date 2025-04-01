import SwiftUI
import FamilyControls

struct ContentView: View {
    @StateObject private var blockerState = AppBlockerState()
    @State private var isShowingFamilyPicker = false
    @State private var activitySelection = FamilyActivitySelection()
    
    private let nfcReader = NFCReader()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(blockerState.isBlocking ? .green : .gray)

            Text(blockerState.isBlocking ? "Blocking ON" : "Blocking OFF")
                .font(.title)

            Button("Scan NFC Tag") {
                nfcReader.beginScan()
            }

            Button("Select Apps to Block") {
                isShowingFamilyPicker = true
            }

            Button("Toggle Blocking") {
                AppBlockerManager.shared.toggleBlocking()
            }
        }
        .padding()
        .familyActivityPicker(isPresented: $isShowingFamilyPicker, selection: $activitySelection)
        .onChange(of: activitySelection) { newSelection in
            AppBlockerManager.shared.updateSelection(newSelection)
        }
    }
}