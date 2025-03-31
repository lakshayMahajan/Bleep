import SwiftUI

struct ContentView: View {
    @StateObject private var blockerState = AppBlockerState()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(blockerState.isBlocking ? .green : .gray)

            Text(blockerState.isBlocking ? "Blocking ON" : "Blocking OFF")
                .font(.title)

            Button(action: {
                AppBlockerManager.shared.toggleBlocking()
            }) {
                Text("Toggle Blocking")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
