import LightwalletClientLib
import Foundation
import SQLite
import ZcashLib

class Sync {
    static func downloadBlocks() async throws {
        let client = LightWalletClient()
        let dbPath = try! Directories.dataDbURLHelper()
        let walletDb = try! ZcashWalletDb.forPath(path: dbPath.path, params: Constants.PARAMS)
        let blocksDirRoot = try! Directories.documentsDirectoryHelper()
        
        try! await client.updateSaplingRoots(walletDb: walletDb)

        let latestHeight: UInt64 = try! await client.getLatestBlock().height

        let rangeStart = latestHeight - Constants.MAX_BLOCKS_TO_SCAN

        let fetchingRange =
            BlockRange.with {
                $0.start = BlockID.with {
                    $0.height = rangeStart
                }
                $0.end = BlockID.with {
                    $0.height = latestHeight
                }
            }

        var blocksIter = client.getBlockRange(range: fetchingRange).makeAsyncIterator()

        while let j: CompactBlock = try! await blocksIter.next() {
            BlocksRepo.write(fsBlocksDbRoot: blocksDirRoot, cbs: [j])
            
            for l in j.vtx {
                try? await fetchTransactionsForBlock(walletDb: walletDb, tx: l)
            }
        }
        
        try! scanCachedBlocks(
            params: Constants.PARAMS,
            fsblockdbRoot: blocksDirRoot.path,
            dbDataPath: dbPath.path,
            height: ZcashBlockHeight(v: UInt32(rangeStart)),
            limit: UInt32(Constants.MAX_BLOCKS_TO_SCAN)
        )
    }

    private static func fetchTransactionsForBlock(walletDb: ZcashWalletDb, tx: CompactTx) async throws {
        let client = LightWalletClient()
        let response = try? await client.getTransaction(txHash: tx.hash)
        let txData = response?.data.map { UInt8($0) }

        let ztx = try? ZcashTransaction.fromBytes(data: txData!, consensusBranchId: ZcashBranchId.sapling)
        try! decryptAndStoreTransaction(params: Constants.PARAMS, zDbData: walletDb, tx: ztx!)
    }

    private static func fetchUtxosForAddress(walletDb: ZcashWalletDb) async throws {
        let client = LightWalletClient()
        let ua = try? walletDb.getCurrentAddress(aid: Constants.ACCOUNT_ID)

        let transparentAddress: ZcashTransparentAddress = (ua?.transparent())!

        let tAddress = transparentAddress.encode(params: Constants.PARAMS)
        var iter = client.getUtxos(tAddress: tAddress).makeAsyncIterator()

        while let l = try! await iter.next() {
            let txIdBytes = l.txid.map { UInt8($0) }
            let index = UInt32(l.index)
            let height = UInt32(l.height)

            putUtxo(
                walletDb: walletDb,
                addressIn: transparentAddress,
                transactionId: txIdBytes,
                index: index,
                value: l.valueZat,
                heightIn: height
            )
        }
    }

    private static func putUtxo(
        walletDb: ZcashWalletDb,
        addressIn: ZcashTransparentAddress,
        transactionId: [UInt8],
        index: UInt32,
        value: Int64,
        heightIn: UInt32
    ) {
        let outPoint = try! ZcashOutPoint(hash: transactionId, n: index)
        let height = ZcashBlockHeight(v: heightIn)
        let txOut = try! ZcashTxOut(value: ZcashAmount(amount: value), scriptPubkey: addressIn.script())

        let output = try! ZcashWalletTransparentOutput.fromParts(outpoint: outPoint, txout: txOut, height: height)

        _ = try! walletDb.putReceivedTransparentUtxo(output: output)
    }
}
