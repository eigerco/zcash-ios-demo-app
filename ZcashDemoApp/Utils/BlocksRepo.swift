import Foundation
import Logging
import ZcashLib
import LightwalletClientLib

class BlocksRepo {
    
    static private func getOutputsCounts(vtxList: Array<CompactTx>) -> (UInt32, UInt32) {
        var outputsCount: Int = 0
        var actionsCount: Int = 0

        vtxList.forEach { compactTx in
            outputsCount += compactTx.outputs.count
            actionsCount += compactTx.actions.count
        }

        return (UInt32(outputsCount), UInt32(actionsCount))
    }
    
    private static func makeBlockFileName(cb: CompactBlock) -> String {
        return [
                "\(cb.height)",
                cb.hash.hexEncodedString().toTxIdString(),
                "compactblock"
        ].joined(separator: "-")
    }
    
    private static func makeBlockMeta(cb: CompactBlock) -> ZcashBlockMeta {
        let height = ZcashBlockHeight(v: UInt32(cb.height))
        let hash = ZcashBlockHash.fromSlice(fromBytes: Array(cb.hash))
        let (saplingOutputsCount, orchardOutputsCount) = getOutputsCounts(vtxList: cb.vtx)
        
        return ZcashBlockMeta(
            height: height,
            blockHash: hash,
            blockTime: cb.time,
            saplingOutputsCount: saplingOutputsCount,
            orchardActionsCount: orchardOutputsCount
        )
    }
    
    static func write(fsBlocksDbRoot: URL, cbs: [CompactBlock]) {
        let blocksDirectory: URL = fsBlocksDbRoot.appendingPathComponent("blocks", isDirectory: true)
        
        // first save the block as file
        // then save the block to the database
        let blockMeta = try! cbs.map { cb in
            let blockFileName = makeBlockFileName(cb: cb)
            
            let blockURL = blocksDirectory.appendingPathComponent(blockFileName)
            
            try ((try? cb.serializedData()) ?? Data()).write(to: blockURL, options: .atomic)
            
            return makeBlockMeta(cb: cb)
        }
        
        let fsBlocksDb = try! ZcashFsBlockDb.forPath(fsblockdbRoot: fsBlocksDbRoot.path)
        try! fsBlocksDb.writeBlockMetadata(blockMeta: blockMeta)
    }
}
