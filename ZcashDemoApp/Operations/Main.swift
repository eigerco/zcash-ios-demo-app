import Foundation
import Logging
import ZcashLib
import SQLite3

class Main {
    // Resets and initializes the wallet database
    static func resetWalletDb() async throws {
        let dbPath = try! Directories.dataDbURLHelper()
        let walletDb = try! ZcashWalletDb.forPath(path: dbPath.path, params: Constants.PARAMS)
        
        if FileManager.default.fileExists(atPath: dbPath.path) {
            try! FileManager.default.removeItem(at: dbPath)
        }

        try! walletDb.initialize(seed: Constants.SEED)

        let birthday = try await getUpdatedAccountBirthday()

        _ = try! walletDb.createAccount(seed: Constants.SEED, birthday: birthday)
    }
    
    private static func createSQLiteFile(blocksDbPath: URL) {
        var db:OpaquePointer? = nil
        
        if sqlite3_open(blocksDbPath.path, &db) != SQLITE_OK {
            print("error opening database, code: " + String(sqlite3_open(blocksDbPath.path, &db)))
        } else {
            print("SUCCESS opening database")
        }
    }

    static func listContents(of url: URL) throws {
        let fileManager = FileManager.default
        
        do {
            let conts = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            conts.forEach {x in
                print(x.path)
            }
        } catch {
            print("can't see the dir")
        }
    }
    
    static func resetBlocksDb() {
        let dbPath = try! Directories.dataDbURLHelper()
        let blocksDirRoot = dbPath.deletingLastPathComponent()
        
        let blocksDirectory: URL = blocksDirRoot.appendingPathComponent("blocks", isDirectory: true)
        if FileManager.default.fileExists(atPath: blocksDirectory.path) {
            try! FileManager.default.removeItem(atPath: blocksDirectory.path)
        }
        
        let blocksDb = try! ZcashFsBlockDb.forPath(fsblockdbRoot: blocksDirRoot.path)
        
        try! blocksDb.initialize(blocksDir: blocksDirRoot.path)
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

    static func getWalletSummary() throws -> String {
        let dbPath = try! Directories.dataDbURLHelper()
        let walletDb = try! ZcashWalletDb.forPath(path: dbPath.path, params: Constants.PARAMS)
        
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

        let logger = Logger(label: "wallet summary")
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
