import SwiftUI
import FamilyControls
import ManagedSettings

struct ContentView: View {
    @State private var isSetupComplete = false
    @StateObject private var blockerState = AppBlockerState()
    @State private var isShowingFamilyPicker = false
    @State private var activitySelection = FamilyActivitySelection()

    private let nfcReader = NFCReader()

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(blockerState.isBlocking ? .bleepPrimary : .gray)

            Text("Ble*p")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(blockerState.isBlocking ? "Apps are currently blocked" : "Apps are not blocked")
                .font(.headline)
                .foregroundColor(blockerState.isBlocking ? .bleepPrimary : .gray)

            if isSetupComplete {
                nfcButtonView
            } else {
                setupButtonsView
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            checkAuthorizationStatus { authorized in
                isSetupComplete = authorized
                activitySelection = AppBlockerManager.shared.selection
            }
        }
    }

    // MARK: - Setup View

    private var setupButtonsView: some View {
        VStack(spacing: 20) {
            Button(action: {
                AppBlockerManager.shared.requestAuthorization { success in
                    if success {
                        isShowingFamilyPicker = true
                    }
                }
            }) {
                Text("Setup App Blocking")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.bleepPrimary)
                    .cornerRadius(12)
            }

            Text("You'll need to select which apps or categories to block")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .familyActivityPicker(isPresented: $isShowingFamilyPicker, selection: $activitySelection)
        .onChange(of: activitySelection) { newSelection in
            AppBlockerManager.shared.updateSelection(newSelection)
            DispatchQueue.main.async {
                isSetupComplete = true
            }
        }
    }

    // MARK: - NFC Toggle + App Re-Selection View

    private var nfcButtonView: some View {
        VStack(spacing: 20) {
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

            // ✅ Only show when not blocking
            if !blockerState.isBlocking {
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
        }
        .familyActivityPicker(isPresented: $isShowingFamilyPicker, selection: $activitySelection)
        .onChange(of: activitySelection) { newSelection in
            AppBlockerManager.shared.updateSelection(newSelection)
        }
    }
    // MARK: - Authorization Helper

    private func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                DispatchQueue.main.async { completion(true) }
            } catch {
                if error.localizedDescription.contains("already") {
                    DispatchQueue.main.async { completion(true) }
                } else {
                    DispatchQueue.main.async { completion(false) }
                }
            }
        }
    }
}
