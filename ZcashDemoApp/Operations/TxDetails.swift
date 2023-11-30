import Foundation
import ZcashLib

enum TxDetails {
    
    static func getFormattedTextForTxDetails(walletDb: ZcashWalletDb, ztx: ZcashTransaction, zht: ZcashBlockHeight) async throws -> String {
        // There are several pieces of information to be gathered
        // for a transaction, mostly for shielded transactions on Sapling and Orchard
        var sb = ""

        let transparentBundle = ztx.transparentBundle()
        if transparentBundle?.vout().count != nil {
            sb.appendLine("This transaction is transparent or deshielding", "")
            sb.appendNumber("# of transparent inputs", transparentBundle!.vin().count)
            sb.appendNumber("# of transparent outputs", transparentBundle!.vout().count)
            try transparentBundle?.vout().enumerated().forEach { idx, it in
                sb.appendNumber("# of VOUT", idx)

                let recAddress = it.recipientAddress()!.encode(params: Constants.PARAMS)
                let amountSpent = it.value().value()
                let pubKey = it.scriptPubkey()

                sb.appendLine("transparent vout - recipient address", recAddress)
                sb.appendNumber("transparent vout - amount spent", UInt64(amountSpent))
                try sb.appendLine("transparent vout - script pub key", String(cString: pubKey.toBytes()))
            }
        }

        let saplingBundle = ztx.saplingBundle()

        if saplingBundle?.shieldedOutputs() != nil {
            sb.appendLine(" - This transaction is shielding or shielded", "")

            sb.appendNumber(" - # of shielded spends (inputs)", saplingBundle!.shieldedSpends().count)
            sb.appendNumber(" - # of shielded outputs", saplingBundle!.shieldedOutputs().count)

            // The transaction is protected for everyone but for the sender of these transactions.
            // If the database contains an Account with the proper viewing keys,
            // the code below will be able to show some information.
            // Otherwise, everything below will be masked.
            let ufvks = try walletDb.getUnifiedFullViewingKeys()
            let decryptedOutput = decryptTransaction(params: Constants.PARAMS, height: zht, tx: ztx, ufvks: ufvks)
            sb.appendLine("Below, the decrypted output", "")
            decryptedOutput.forEach { it in
                sb.appendLine("------------------", "")
                sb.appendNumber(" - index", it.index())
                sb.appendNumber(" - note value", it.note().value().inner())
                sb.appendNumber(" - account ID", it.account().id)
                sb.appendLine(" - memo", Data(it.memo().data()).hexEncodedString())
                sb.appendLine(" - transfer type", String(it.transferType().hashValue))
            }
        }
        return sb
    }
    /**
     * To extract information from a shielded transaction we need the viewing keys in the database,
     * otherwise we would need only the txHash information.
     */
    static func getFormattedTextForTxDetails(walletDb: ZcashWalletDb, txHash: String) async throws -> String {
        // There are much better ways to handle async jobs,
        // but in this case we just need the transaction to be processed further.
        let (ztx, zht) = await getTransactionAndHeightFromHash(txHash: txHash)
        
        return try! await getFormattedTextForTxDetails(walletDb: walletDb, ztx: ztx, zht: zht)
    }

    private static func getTransactionAndHeightFromHash(txHash: String) async -> (ZcashTransaction, ZcashBlockHeight) {
        let bytesFromHex = Data(fromHexEncodedString: txHash)!
        let rawTransaction = try! await LightWalletClient().getTransaction(txHash: bytesFromHex)
        // Most UniFFI functions in the library use unsigned integers,
        // so this is a common situation
        let txData = Array(rawTransaction.data)
        // The height is needed for decrypting shielded outputs
        let zht = ZcashBlockHeight(v: UInt32(rawTransaction.height))
        // SAPLING because the library doesn't support Orchard yet,
        // but in the future this might change
        return (try! ZcashTransaction.fromBytes(data: txData, consensusBranchId: ZcashBranchId.sapling), zht)
    }
}
