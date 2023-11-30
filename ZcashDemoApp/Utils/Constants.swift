import ZcashLib

enum Constants {
    // params used (mainNetwork available too)
    static let PARAMS = ZcashConsensusParameters.testNetwork
    
    // max amount of retrograde blocks
    static let MAX_BLOCKS_TO_SCAN: UInt64 = 20
    
    // fixed because at any point in time we will have only one account in the DB
    static let ACCOUNT_ID = ZcashAccountId(id: 0)
    
    // needs to be set manually when testing wallet usage
    static let WALLET_BIRTHDAY_HEIGHT = UInt64(2610599)
    
    // coordinates to remote node used
    static let NETWORK_ADDRESS = "lightwalletd.testnet.electriccoin.co"
    static let NETWORK_PORT = 9067
    
    // max utxos to download for one transparent address
    static let MAX_UTXOS: UInt32 = 10

    // Minimum confirmations for considering a transaction valid
    static let MIN_CONFIRMATIONS = UInt32(1)
    
    // Must be at least 32 bytes
    static let SEED: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 11, 8, 9, 10, 13, 12, 13, 14, 15, 176, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    
    // some recipient address generated earlier which was used for testing
    static let RECIPIENT_ADDRESS = "ztestsapling1yfp9e7m2xze0zkhhj7y6k26gepwa6z3a27kq3ngxpl455vp26dv7jc9cv2wa3phngyz967qj88h"
    
    // useful to get last tx id submitted
    // the important thing is that it's the same for all instances in which it's used
    static let LAST_TX_ID_LABEL = "some key"
}
