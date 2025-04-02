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
                .frame(width: 80, height: 80)
                .foregroundColor(blockerState.isBlocking ? .bleepPrimary : .gray)

            Text("Ble*p")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(blockerState.isBlocking ? "Apps are currently blocked" : "Apps are not blocked")
                .font(.headline)
                .foregroundColor(blockerState.isBlocking ? .bleepPrimary : .gray)

            Button(action: {
                nfcReader.beginScan()
            }) {
                HStack {
                    Image(systemName: "wave.3.right")
                    Text("Scan NFC Tag")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.bleepPrimary)
                .cornerRadius(12)
            }

            Button(action: {
                isShowingFamilyPicker = true
            }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Select Apps to Block")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.bleepPrimary)
                .cornerRadius(12)
            }
        }
        .padding()
        .familyActivityPicker(isPresented: $isShowingFamilyPicker, selection: $activitySelection)
        .onChange(of: activitySelection) { newSelection in
            AppBlockerManager.shared.updateSelection(newSelection)
        }
    }
}
