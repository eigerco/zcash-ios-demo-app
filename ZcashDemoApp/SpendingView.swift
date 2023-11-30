import SwiftUI
import ZcashLib

struct SpendingView: View {
    @State var showingAlert = false
    @State var showingSubmissionAlert = false
    @State var transactionCreated = false
    @State var amountToSend: UInt64 = 0
    let dbPath: URL
    let walletDb: ZcashWalletDb
    let spendableAmount: UInt64

    init() {
        dbPath = try! Directories.dataDbURLHelper()
        walletDb = try! ZcashWalletDb.forPath(path: dbPath.path, params: Constants.PARAMS)
        spendableAmount = getSpendableAmount(walletDb: walletDb)
    }

    var body: some View {
        VStack {
            LabelTextRow(
                label: "Spendable amount",
                text: String(spendableAmount)
            ).padding()

            TextField("Amount in ZATs to send",
                      value: $amountToSend,
                      formatter: NumberFormatter())
                .frame(width: 180)
                .background(.yellow)
                .padding()

            StandardButton(label: "Create Transaction") {
                if spendableAmount > 0 {
                    transactionCreated = createTransaction(walletDb: walletDb, amountToSend: amountToSend)
                    showingAlert = true
                } else {
                    transactionCreated = false
                    showingAlert = true
                }
            }.alert("Notification", isPresented: $showingAlert) {} message: {
                if spendableAmount < amountToSend {
                    Text("You need to have some notes in the wallet to spend something!")
                } else {
                    Text("Transaction created: \(String(transactionCreated))")
                }
            }.padding()
            AsyncButton(label: "Submit Transaction") {
                await Spending.submitTransaction()
                showingSubmissionAlert = true
            }
            .alert("Transaction submitted", isPresented: $showingSubmissionAlert) {}
            .padding()
        }
    }
}

/**
 * Trying to reduce the amount of exceptions that may occur in the UI
 */
private func getSpendableAmount(walletDb: ZcashWalletDb) -> UInt64 {
    do {
        return try Spending.spendableAmount(walletDb: walletDb)
    } catch (_) {
        return 0
    }
}

private func createTransaction(walletDb: ZcashWalletDb, amountToSend: UInt64) -> Bool {
    if amountToSend > 0 {
        let txRequest = Spending.makeTransactionRequest(memoBytes: [], addressTo: Constants.RECIPIENT_ADDRESS, amount: Int64(amountToSend))
        let _ = Spending.createTransaction(walletDb: walletDb, request: txRequest)
        return true
    } else {
        return false
    }
}

#Preview {
    SpendingView()
}
