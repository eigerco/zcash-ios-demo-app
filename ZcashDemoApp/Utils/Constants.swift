import ZcashLib

enum Constants {
    static let PARAMS = ZcashConsensusParameters.testNetwork
    static let MAX_BLOCKS_TO_SCAN: UInt64 = 60
    static let ACCOUNT_ID = ZcashAccountId(id: 0)
    static let WALLET_BIRTHDAY_HEIGHT = UInt64(0)
    static let NETWORK_ADDRESS = "lightwalletd.testnet.electriccoin.co"
    static let NETWORK_PORT = 9067
    static let MAX_UTXOS: UInt32 = 10

    static let MIN_CONFIRMATIONS = UInt32(60)
    static let SEED: [UInt8] = [0, 1, 2, 3]
    static let RECIPIENT_ADDRESS = ""
}
