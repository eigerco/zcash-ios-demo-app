import SwiftUI
import ZcashLib

struct MainView: View {
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    @State private var showingAlert3 = false
    @State private var text = getWalletSummary()

    var body: some View {
        VStack(alignment: .center) {
            TextCardView(title: "Transaction details", text: text)

            AsyncButton(label: "Reset wallet database") {
                try await Main.resetWalletDb()
                showingAlert1 = true
            }
            .alert("Wallet DB reset!", isPresented: $showingAlert1) {}
            .padding()
            
            StandardButton(label: "Reset blocks database") {
                Main.resetBlocksDb()
                showingAlert2 = true
            }
            .alert("Blocks DB reset!", isPresented: $showingAlert2) {}
            .padding()
            
            AsyncButton(label: "Download blocks") {
                try! await Sync.downloadBlocks()
                showingAlert3 = true
            }
            // the alert above is shown??
            .alert("Blocks downloaded!", isPresented: $showingAlert3) {}
            .padding()
            
            StandardButton(label: "Update from DB") {
                text = getWalletSummary()
            }
            .padding()

            NavigationLink(destination: MenuView()) {
                Text("Go to menu")
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }
}

func getWalletSummary() -> String {
    do {
        return try Main.getWalletSummary()
    } catch {
        return "DB not initialized"
    }
}

#Preview {
    MainView()
}
