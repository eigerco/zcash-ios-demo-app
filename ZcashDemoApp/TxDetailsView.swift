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
        walletDb = try! ZcashWalletDb.forPath(path: dbPath.path, params: Constants.PARAMS)
    }

    var body: some View {
        // https://stackoverflow.com/q/70981389/1096030
        VStack {
            TextField("Transaction hash", text: $txHash)
                .frame(width: 300)
                .background(.yellow)
                .alert("The transaction hash is invalid!", isPresented: $showingAlert) {}
                .padding()
            if txHash.count == 64 {
                StandardButton(label: "Try get pasted hash") {
                    if txHash.count == 64 {
                        Task {
                            text = try await TxDetails.getFormattedTextForTxDetails(walletDb: walletDb, txHash: txHash)
                        }
                    } else {
                        showingAlert = true
                    }
                }
            }
            StandardButton(label: "Paste test transaction") {
                txHash = "ae56a57170f3e6fb397d84e1d5dfe2098c7c5bddf1c3dc14cac3080051247ade"
            }
            StandardButton(label: "Explore last tx") {
                Task {
                    let txIdByteArray = UserDefaults.standard.array(forKey: Constants.LAST_TX_ID_LABEL) as! [UInt8]
                    let parsedTxId = try! ZcashTxId.fromBytes(data: txIdByteArray)
                    let tx = try! walletDb.getTransaction(txid: parsedTxId)
                    
                    text = try await TxDetails.getFormattedTextForTxDetails(walletDb: walletDb, ztx: tx, zht: tx.expiryHeight())
                }
            }
            TextCardView(title: "Transaction details", text: text)
        }
    }
}

#Preview {
    TxDetailsView()
}
