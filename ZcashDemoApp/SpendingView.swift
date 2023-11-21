import SwiftUI
import ZcashLib

struct SpendingView: View {
    let dbPath = try! Directories.dataDbURLHelper()
    
    var body: some View {
        @State var showingAlert = false
        @State var transactionCreated = false
        @State var amountToSend: UInt64 = 0
        
        let walletDb = try! ZcashWalletDb.forPath(path: dbPath.absoluteString, params: Constants.PARAMS)
        let spendableAmount = getSpendableAmountOrToast(walletDb: walletDb)
        
        VStack {
            LabelTextRow(
                label: "Spendable amount",
                text: String(spendableAmount)
            )
            TextField ("Amount in ZATs to send",
                       value: $amountToSend,
                       formatter: NumberFormatter()
            )
            StandardButton(label: "Create Transaction") {
                if spendableAmount > 0 {
                    transactionCreated = createTransaction(walletDb: walletDb, amountToSend: amountToSend)
                    showingAlert = true
                } else {
                    transactionCreated = false
                    showingAlert = true
                }
            }.alert("Notification", isPresented: $showingAlert) {
                Button("OK") {
                    showingAlert = false
                }
            } message: {
                if spendableAmount < 0 {
                    Text("You need to have some notes in the wallet to spend something!")
                } else {
                    Text("Transaction created: \(String(transactionCreated))")
                }
                
            }
            StandardButton(label: "Submit Transaction") {
                Spending.submitTransaction()
            }
        }
    }
}


/**
 * Trying to reduce the amount of exceptions that may occur in the UI
 */
private func getSpendableAmountOrToast(walletDb: ZcashWalletDb) -> Int64 {
     do {
        let amount = try Spending.spendableAmount(walletDb: walletDb)
        return Int64(amount)
    } catch(_) {
        return -1
    }
}


private func createTransaction(walletDb: ZcashWalletDb, amountToSend: UInt64) -> Bool {
    if(amountToSend > 0) {
        let txRequest = Spending.makeTransactionRequest(memoBytes: [], addressTo: Constants.RECIPIENT_ADDRESS, amount: Int64(amountToSend))
        Spending.createTransaction(walletDb: walletDb, request: txRequest)
        return true
    } else {
        return false
    }
}

#Preview {
    SpendingView()
}
