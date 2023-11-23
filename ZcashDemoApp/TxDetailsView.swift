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
        dbPath = try! Directories.dataDbURLHelper()
        walletDb = try! ZcashWalletDb.forPath(path: dbPath.absoluteString, params: Constants.PARAMS)
    }

    var body: some View {
        // https://stackoverflow.com/q/70981389/1096030
        VStack {
            TextField("Transaction hash", text: $txHash)
                .onSubmit {
                    if txHash.count == 64 {
                        Task {
                            text = try await TxDetails.getFormattedTextForTxDetails(walletDb: walletDb, txHash: txHash)
                        }
                    } else {
                        showingAlert = true
                    }
                }
                .frame(width: 300)
                .background(.yellow)
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
