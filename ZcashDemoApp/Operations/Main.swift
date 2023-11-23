
import Logging
import ZcashLib

// Simulates StringBuilder from kotlin
public extension String {
    mutating func appendLine(_ value: String) {
        append(String(format: "%@\n", value))
    }

    mutating func appendLine(_ key: String, _ value: String) {
        append(String(format: "%@:%@\n", key, value))
    }

    mutating func appendNumber(_ key: String, _ value: UInt32) {
        append(String(format: "%@: %@\n", key, value))
    }

    mutating func appendNumber(_ key: String, _ value: UInt64) {
        append(String(format: "%@: %@\n", key, value))
    }

    mutating func appendNumber(_ key: String, _ value: Int) {
        append(String(format: "%@: %@\n", key, value))
    }
}

enum Main {
    // Resets and initializes the wallet database
    static func resetWalletDb(walletDb: ZcashWalletDb) async throws {
        // TODO: destroy db

        try! walletDb.initialize(seed: Constants.SEED)

        let birthday = try await getUpdatedAccountBirthday()

        _ = try! walletDb.createAccount(seed: Constants.SEED, birthday: birthday)
    }

    static func resetBlocksDb(_ blocksDir: String) {
        try! ZcashFsBlockDb.forPath(fsblockdbRoot: blocksDir).initialize(blocksDir: blocksDir)
    }

    private static func getUpdatedAccountBirthday() async throws -> ZcashAccountBirthday {
        let client = LightWalletClient()
        // Retrieves the (Sapling) TreeState from the birth of the wallet
        let response = try await client.getTreeState(value: Constants.WALLET_BIRTHDAY_HEIGHT)
        let treeState = try response.serializedData(partial: false)

        // Atomizes all information for the wallet to be used locally (for spending, for example)
        let birthHeight = ZcashBlockHeight(v: UInt32(Constants.WALLET_BIRTHDAY_HEIGHT))
        let birthState = try ZcashTreeState.fromBytes(bytes: Array(treeState))
        return try ZcashAccountBirthday.fromTreestate(treestate: birthState, recoverUntil: birthHeight)
    }

    enum WalletSummaryError: Error {
        case DbNotAvailable
    }

    static func getWalletSummary(walletDb: ZcashWalletDb) throws -> String {
        let chainTipHeight: UInt32
        let fullyScannedHeight: UInt32
        let isWalletSynced: Bool
        let walletAccountBalances: [String: ZcashAccountBalance]

        if let walletSummary = try walletDb.getWalletSummary(minConfirmations: Constants.MIN_CONFIRMATIONS) {
            chainTipHeight = walletSummary.chainTipHeight().value()
            fullyScannedHeight = walletSummary.fullyScannedHeight().value()
            isWalletSynced = walletSummary.isSynced()
            walletAccountBalances = walletSummary.accountBalances()
        } else {
            throw WalletSummaryError.DbNotAvailable
        }

        let unifiedAddress = try walletDb.getCurrentAddress(aid: Constants.ACCOUNT_ID)
        let transparentAddress = (unifiedAddress?.transparent()!.encode(params: Constants.PARAMS))!
        let saplingAddress = (unifiedAddress?.sapling()!.encode(params: Constants.PARAMS))!

        let amountDefiningSpendable = try ZcashAmount(amount: 10000)
        let anchorHeight = try walletDb.getTargetAndAnchorHeights(minConfirmations: Constants.MIN_CONFIRMATIONS)!.anchorHeight
        let walletBirthdayHeight = try walletDb.getWalletBirthday()!.value()
        let spendableNotes = try walletDb.selectSpendableSaplingNotes(account: Constants.ACCOUNT_ID, targetValue: amountDefiningSpendable, anchorHeight: anchorHeight, exclude: [])

        let logger = Logger(label: "info")
        logger.log(level: .info, "Transparent address: \(transparentAddress)")
        logger.log(level: .info, "Sapling address: \(saplingAddress)")

        var ws = ""

        ws.appendLine("Transparent address", transparentAddress)
        ws.appendLine("Sapling address", saplingAddress)
        ws.appendNumber("Chain tip height", chainTipHeight)
        ws.appendLine("Synced", String(isWalletSynced))
        ws.appendNumber("Fully synced height", fullyScannedHeight)
        ws.appendNumber("Wallet birthday height", walletBirthdayHeight)

        ws.appendLine("Account balances:")
        walletAccountBalances.forEach { _, zbalance in
            ws.appendNumber("total", zbalance.total().value())
            ws.appendNumber("shielded", zbalance.saplingSpendableValue().value())
            ws.appendNumber("unshielded", zbalance.unshielded().value())
        }

        ws.appendLine("Spendable notes:")
        spendableNotes.forEach { it in
            ws.appendNumber(" - Note value in ZATs", UInt64(it.value().value()))
        }

        return ws
    }
}
