import SwiftUI
import ZcashLib

struct TxDetailsView: View {
    let dbPath = try! Directories.dataDbURLHelper()
    
    var body: some View {
        // contains the transaction details returned by the library
        @State var text = ""
        // contains the transaction hash pasted or entered in the field
        @State var txHash = ""
        @State var showingAlert = false
        let walletDb = try! ZcashWalletDb.forPath(path: dbPath.absoluteString, params: Constants.PARAMS)
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
            .alert("The transaction hash is invalid!", isPresented: $showingAlert) {
                Button("OK") {
                    showingAlert = false
                }
            }
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
