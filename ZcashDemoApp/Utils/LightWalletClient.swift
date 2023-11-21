import Foundation
import GRPC
import LightwalletClientLib
import ZcashLib

class LightWalletClient {
    // This is by default using a remote node, but it is possible to use a local client too.

    static let shared = LightWalletClient()

    private var client: CompactTxStreamerAsyncClient

    init() {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let channel = ClientConnection
            .usingPlatformAppropriateTLS(for: group)
            .connect(host: Constants.NETWORK_ADDRESS, port: Constants.NETWORK_PORT)

        client = CompactTxStreamerAsyncClient(channel: channel)
    }

    func getLatestBlock() async throws -> BlockID {
        try await client.getLatestBlock(ChainSpec())
    }

    func getBlockRange(range: BlockRange) -> AsyncThrowingStream<CompactBlock, Error> {
        AsyncThrowingStream { comb in
            Task {
                for try await blk in self.client.getBlockRange(range) {
                    comb.yield(blk)
                }
                comb.finish()
            }
        }
    }

    func getTransaction(txId: Data) async throws -> RawTransaction {
        try await client.getTransaction(TxFilter.with {
            $0.index = 0
            $0.hash = txId
        })
    }

    func getTreeState(value: UInt64) async throws -> TreeState {
        try await client.getTreeState(BlockID.with {
            $0.height = value
        })
    }

    func getUtxos(tAddress: String) -> AsyncThrowingStream<GetAddressUtxosReply, Error> {
        let request = GetAddressUtxosArg.with {
            $0.addresses = [tAddress]
            $0.maxEntries = Constants.MAX_UTXOS
        }

        return AsyncThrowingStream { comb in
            Task {
                for try await blk in self.client.getAddressUtxosStream(request) {
                    comb.yield(blk)
                }
                comb.finish()
            }
        }
    }

    func submitTransaction(data: Data) async throws -> SendResponse {
        try await client.sendTransaction(RawTransaction.with {
            $0.data = data
        })
    }
}
