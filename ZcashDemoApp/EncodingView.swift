import SwiftUI
import ZcashLib

struct EncodingView: View {
    let dbPath = try! Directories.dataDbURLHelper()
    
    var body: some View {
        @State var uaAddress = ""
        @State var tAddress = ""
        @State var sAddress = ""
        @State var oAddress = ""
        let walletDb = try! ZcashWalletDb.forPath(path: dbPath.absoluteString, params: Constants.PARAMS)
        
        /**
         * the ideal approach would be to save state as ZcashUnifiedAddress and not as a string,
         * but that might end up shadowing our efforts to show off how to use the library.
         * See for example:
         *  - https://developer.android.com/jetpack/compose/state-saving
         *  - https://developer.android.com/kotlin/parcelize
         */
        VStack {
            TextField ("Transaction hash",
                       value: $uaAddress,
                       formatter: Formatter()
            )
            /**
             * hack for quick testing: getting the UA from the account
             * we generated
             */
            StandardButton(label: "Paste test UA from db") {
                uaAddress = try! walletDb.getCurrentAddress(aid: Constants.ACCOUNT_ID)?.encode(params: Constants.PARAMS) ?? ""
            }
            StandardButton(label: "Parse address") {
                let ua = parseUnifiedAddress(address: uaAddress)
                tAddress = getTransparentAddress(ua: ua)
                sAddress = getSaplingAddress(ua: ua)
                oAddress = getOrchardAddress(ua: ua)
            }
            LabelTextRow(
                label: "Transparent address",
                text: tAddress
            )
            LabelTextRow(
                label: "Sapling address",
                text: sAddress
            )
            LabelTextRow(
                label: "Orchard address",
                text: oAddress
            )
        }
    }

    private func parseUnifiedAddress(address: String) -> ZcashUnifiedAddress {
        return try! ZcashUnifiedAddress.decode(params: Constants.PARAMS, address: address)
    }

    private func getTransparentAddress(ua: ZcashUnifiedAddress) -> String {
        return ua.transparent()?.encode(params: Constants.PARAMS) ?? "no tAddress"
    }

    private func getSaplingAddress(ua: ZcashUnifiedAddress) -> String {
        return ua.sapling()?.encode(params: Constants.PARAMS) ?? "no sAddress"
    }

    private func getOrchardAddress(ua: ZcashUnifiedAddress) -> String {
        let bytes = ua.orchard()?.toRawAddressBytes()
        return if (bytes == nil) {
            "no oAddress"
        } else {
            Data(bytes!).hexEncodedString()
        }
    }
}

#Preview {
    EncodingView()
}
