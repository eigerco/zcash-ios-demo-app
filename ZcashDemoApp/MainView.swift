import SwiftUI
import ZcashLib

struct MainView: View {
    let dbPath: URL
    // The Databases are created here, because to create the connection
    // we need the path of the files, and to get those we need the context to be visible.
    // The context in Android is available only under Activities.
    let walletDb: ZcashWalletDb
    // reinitialize the wallet
    let blocksDirRoot: URL
    let text: String
    
    @State private var showingAlert = false
    
    init() {
        self.dbPath = try! Directories.dataDbURLHelper()
        self.walletDb = try! ZcashWalletDb.forPath(path: dbPath.absoluteString, params: Constants.PARAMS)
        self.blocksDirRoot = dbPath.deletingLastPathComponent()
        self.text = getWalletSummary(walletDb: walletDb)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            TextCardView(title: "Transaction details", text: text)
            
            AsyncButton(label: "Reset database") {
                // await Main.resetWalletDb(walletDb: walletDb)
                // Main.initBlocksDb(blocksDirRoot)
                showingAlert = true
            }
            .alert("Database reset!", isPresented: $showingAlert) {}
            .padding()

            AsyncButton(label: "Download blocks") {
                try! await Sync.downloadBlocks(walletDbPath: dbPath.absoluteString, blocksDirRoot: blocksDirRoot.absoluteString)
                showingAlert = true
            }.alert("Blocks downloaded!", isPresented: $showingAlert) {}
            .padding()

            NavigationLink(destination: MenuView()) {
                Text("Go to menu")
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }
}

internal func getWalletSummary(walletDb: ZcashWalletDb) -> String {
    do {
        return try Main.getWalletSummary(walletDb: walletDb)
    } catch {
        return "DB not initialized"
    }
}

#Preview {
    MainView()
}
