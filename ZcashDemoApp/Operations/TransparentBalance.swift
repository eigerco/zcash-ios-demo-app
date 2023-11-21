
import ZcashLib

enum AddressType {
    case transparent
    case sapling
    case orchard
    case unified
    case invalid
}

class TransparentBalance {

    static func isValidTransparentAddress(address: String) -> Bool {
        getAddressType(addr: address) == AddressType.transparent
    }

    static func getBalanceFromTransparentAddress(address: String) async -> Int64 {
        try! await LightWalletClient()
            .getUtxos(tAddress: address)
            .map { u in u.valueZat }
            .reduce(0, +)
    }

    /**
     * This is an exemplary function to show how to decide whose type
     * is the address being given as a string. There was not a good way
     * to solve the issue with the boundaries that UniFFI impose,
     * so we had to work around this. Maybe a good issue for a PR!
     */
    static private func getAddressType(addr: String) -> AddressType {
        let transparentAddress = try? ZcashTransparentAddress.decode(params: Constants.PARAMS, input: addr)

        let saplingAddress = try? ZcashPaymentAddress.decode(params: Constants.PARAMS, input: addr)

        let bytes = Array(addr.data(using: .utf8)!)

        let orchardAddress = try? ZcashOrchardAddress.fromRawAddressBytes(bytes: bytes)

        let unifiedAddress = try? ZcashUnifiedAddress.decode(params: Constants.PARAMS, address: addr)

        return if transparentAddress != nil {
            AddressType.transparent
        } else if saplingAddress != nil {
            AddressType.sapling
        } else if orchardAddress != nil {
            AddressType.orchard
        } else if unifiedAddress != nil {
            AddressType.unified
        } else {
            AddressType.invalid
        }
    }
}
