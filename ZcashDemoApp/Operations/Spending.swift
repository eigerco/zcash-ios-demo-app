import Foundation
import ZcashLib

class Spending {
    private let client = LightWalletClient()

    static let LAST_TX_ID_LABEL = "some key"

    static func submitTransaction() {
//        let txIdByteArray = UserDefaults.standard.array(forKey: LAST_TX_ID_LABEL) as! [UInt8]

//        val byteArray = FirstClassByteArray(txIdByteArray)

//        let parsedTxId = try! ZcashTxId.fromBytes(data: txIdByteArray)
//        let dbPath = try! Directories.dataDbURLHelper().path()
//        let walletDb = try! ZcashWalletDb.forPath(path: dbPath, params: Constants.PARAMS)

//        let encodedTransaction = walletDb.findEncodedTransactionByTxId(txIdByteArray)
//        client.submitTransaction(data: encodedTransaction!!.raw)
    }

    static func makeTransactionRequest(
        memoBytes: [UInt8],
        addressTo: String,
        amount: Int64
    ) -> ZcashTransactionRequest {
        let recAddress = try! ZcashRecipientAddress.decode(params: Constants.PARAMS, address: addressTo)

        // if the address is shielded, include the memo, otherwise
        // set null, as the transparent or deshielding transaction
        // cannot contain a memo field
        let memoField: ZcashMemoBytes? =
            if addressTo.contains("sapling")
        {
            try! ZcashMemoBytes(data: memoBytes)
        } else {
            nil
        }

        let payment = ZcashPayment(
            recipientAddress: recAddress,
            amount: try! ZcashAmount(amount: amount),
            memo: memoField,
            label: "label",
            message: "message",
            otherParams: []
        )

        return try! ZcashTransactionRequest(payments: [payment])
    }

    private static func makeProver() -> ZcashLocalTxProver {
        let outputParams = try! Directories.outputParamsURLHelper().path()
        let spendParams = try! Directories.spendParamsURLHelper().path()
        return ZcashLocalTxProver(spendPath: spendParams, outputPath: outputParams)
    }

    static func spendableAmount(walletDb: ZcashWalletDb) throws -> UInt64 {
        if let heightsPair = try walletDb.getTargetAndAnchorHeights(minConfirmations: Constants.MIN_CONFIRMATIONS) {
            try UInt64(walletDb.selectSpendableSaplingNotes(account: Constants.ACCOUNT_ID, targetValue: ZcashAmount(amount: 10000), anchorHeight: heightsPair.anchorHeight, exclude: []).reduce(0) { $0 + $1.value().value() })
        } else {
            UInt64(0)
        }
    }

    static func createTransaction(
        walletDb: ZcashWalletDb,
        request: ZcashTransactionRequest
    ) -> ZcashTxId {
        let zusk = try! ZcashUnifiedSpendingKey.fromSeed(params: Constants.PARAMS, seed: Constants.SEED, accountId: Constants.ACCOUNT_ID)

        let zdop = ZcashDustOutputPolicy(action: ZcashDustAction.reject, dustThreshold: nil)

        // Here the fee rule is the pre-ZIP-317 standard fixed fee.
        let fixedRule = ZcashFixedFeeRule.standard()

        let fixedChangeStrategy = ZcashFixedSingleOutputChangeStrategy(feeRule: fixedRule)

        let prover = makeProver()

        let txId: ZcashTxId

        switch Constants.PARAMS {
        case ZcashConsensusParameters.testNetwork:
            let inputSelector = ZcashTestFixedGreedyInputSelector(changeStrategy: fixedChangeStrategy, dustOutputPolicy: zdop)
            txId = try! spendTestFixed(
                zDbData: walletDb,
                params: Constants.PARAMS,
                prover: prover,
                inputSelector: inputSelector,
                usk: zusk,
                request: request,
                ovkPolicy: ZcashOvkPolicy.sender,
                minConfirmations: Constants.MIN_CONFIRMATIONS
            )

        case ZcashConsensusParameters.mainNetwork:
            let inputSelector = ZcashMainFixedGreedyInputSelector(changeStrategy: fixedChangeStrategy, dustOutputPolicy: zdop)
            txId = try! spendMainFixed(
                zDbData: walletDb,
                params: Constants.PARAMS,
                prover: prover,
                inputSelector: inputSelector,
                usk: zusk,
                request: request,
                ovkPolicy: ZcashOvkPolicy.sender,
                minConfirmations: Constants.MIN_CONFIRMATIONS
            )
        }

        saveTransactionId(txId: txId)

        return txId
    }

    private static func saveTransactionId(txId: ZcashTxId) {
        UserDefaults.standard.set(try! txId.toBytes(), forKey: LAST_TX_ID_LABEL)
    }
}
