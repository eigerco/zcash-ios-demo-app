import SwiftUI
import ZcashLib

struct TxDetailsView: View {
    // contains the transaction details returned by the library
    @State private var text = ""
    // contains the transaction hash pasted or entered in the field
    @State private var txHash = ""
    // alert flag
    @State private var showingAlert = false
    
    let dbPath: URL
    let walletDb: ZcashWalletDb
    
    init() {
        self.dbPath = try! Directories.dataDbURLHelper()
        self.walletDb = try! ZcashWalletDb.forPath(path: dbPath.absoluteString, params: Constants.PARAMS)
    }
    
    var body: some View {
        // https://stackoverflow.com/questions/70981389/how-to-center-a-scrollable-text-in-swiftui
        VStack {
            TextField ("Transaction hash",
                       value: $txHash,
                       formatter: Formatter()
            )
            .onSubmit {
                if (txHash.count == 64) {
                    // WEIRD - no errors thrown?
                    Task {
                        text = try await TxDetails.getFormattedTextForTxDetails(walletDb: walletDb, txHash: txHash)
                    }
                } else {
                    showingAlert = true
                }
            }
            .alert("The transaction hash is invalid!", isPresented: $showingAlert) {}
            .padding()
            StandardButton(label: "Paste test transaction") {
              txHash = "8b36745d1b29bfcb3836e13dbdc1b749a6b1f9485b83d929e561a2a89004fd55"
            }
            TextCardView(title: "Transaction details", text: text)
        }
    }
}

#Preview {
    TxDetailsView()
}
