import SwiftUI
import ZcashLib

struct MainView: View {
    // reinitialize the wallet
    let dbPath = try! Directories.dataDbURLHelper()


    var body: some View {
        // The Databases are created here, because to create the connection
        // we need the path of the files, and to get those we need the context to be visible.
        // The context in Android is available only under Activities.
        let walletDb = try! ZcashWalletDb.forPath(path: dbPath.absoluteString, params: Constants.PARAMS)
        let blocksDirRoot = dbPath.deletingLastPathComponent()
        @State var showingAlert = false

        VStack {
            AsyncButton(label: "Reset database") {
                await Main.resetWalletDb(walletDb: walletDb)
//                Main.initBlocksDb(blocksDirRoot)
                showingAlert = true
            }.alert(isPresented: $showingAlert) {
                showingAlert = false
                return Alert(
                    title: Text("Notification"),
                    message: Text("Blocks downloaded!")
                )
            }

            AsyncButton(label: "Download blocks") {
                try! await Sync.downloadBlocks(walletDbPath: dbPath.absoluteString, blocksDirRoot: blocksDirRoot.absoluteString)
                showingAlert = true
            }.alert(isPresented: $showingAlert) {
                showingAlert = false
                return Alert(
                    title: Text("Notification"),
                    message: Text("Blocks downloaded!")
                )
            }

            NavigationLink {
                MenuView()
            } label: {
                Text("Go to menu")
            }
        }
    }
}

#Preview {
    MainView()
}
