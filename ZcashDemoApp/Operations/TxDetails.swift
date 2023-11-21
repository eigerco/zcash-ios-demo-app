import Foundation
import ZcashLib

class TxDetails {
    /**
     * To extract information from a shielded transaction we need the viewing keys in the database,
     * otherwise we would need only the txHash information.
     */
    static func getFormattedTextForTxDetails(walletDb: ZcashWalletDb, txHash: String) async throws -> String {
        // There are much better ways to handle coroutines jobs,
        // but in this case we just need the transaction to be processed further.
        let (ztx, zht) = await getTransactionAndHeightFromHash(txHash: txHash)

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
                sb.appendLine("transparent vout - script pub key", try String(cString: pubKey.toBytes()))
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

    private static func getTransactionAndHeightFromHash(txHash: String) async -> (ZcashTransaction, ZcashBlockHeight) {
        let bytesFromHex = Data(fromHexEncodedString: txHash)!
        let rawTransaction = try! await LightWalletClient().getTransaction(txId: bytesFromHex)
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

extension Data {
    init?(fromHexEncodedString string: String) {
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(bytes: UInt16) -> UInt8? {
            switch bytes {
            case 0x30 ... 0x39:
                UInt8(bytes - 0x30)
            case 0x41 ... 0x46:
                UInt8(bytes - 0x41 + 10)
            case 0x61 ... 0x66:
                UInt8(bytes - 0x61 + 10)
            default:
                nil
            }
        }

        self.init(capacity: string.utf16.count / 2)
        var even = true
        var byte: UInt8 = 0
        for char in string.utf16 {
            guard let val = decodeNibble(bytes: char) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                append(byte)
            }
            even.toggle()
        }
        guard even else { return nil }
    }
}

public extension Data {
    func asZcashTransactionMemo() -> String? {
        String(data: self, encoding: .utf8)
    }
}

/**
 Attempts to convert this string to a Zcash Transaction Memo data
 */
public extension String {
    func encodeAsZcashTransactionMemo() -> Data? {
        data(using: .utf8)
    }
}

struct HexEncodingOptions: OptionSet {
    public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension Data {
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        z_hexEncodedString(data: self, options: options)
    }
}

func z_hexEncodedString(data: Data, options: HexEncodingOptions = []) -> String {
    let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
    var chars: [unichar] = []

    chars.reserveCapacity(2 * data.count)
    for byte in data {
        chars.append(hexDigits[Int(byte / 16)])
        chars.append(hexDigits[Int(byte % 16)])
    }

    return String(utf16CodeUnits: chars, count: chars.count)
}
