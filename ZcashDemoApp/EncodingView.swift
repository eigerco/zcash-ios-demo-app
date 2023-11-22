import SwiftUI
import ZcashLib

struct EncodingView: View {
    /**
     * the ideal approach would be to save state as ZcashUnifiedAddress and not as a string,
     * but that might end up shadowing our efforts to show off how to use the library.
     */
    @State private var uaAddress = ""
    @State private var tAddress = ""
    @State private var sAddress = ""
    @State private var oAddress = ""
    
    let dbPath: URL
    let walletDb: ZcashWalletDb
    
    init() {
        self.dbPath = try! Directories.dataDbURLHelper()
        self.walletDb = try! ZcashWalletDb.forPath(path: dbPath.absoluteString, params: Constants.PARAMS)
    }
    
    var body: some View {
        
        VStack {
            TextField ("Transaction hash", text: $uaAddress).padding()
            /**
             * hack for quick testing: getting the UA from the account
             * we generated
             */
            StandardButton(label: "Paste test UA from db") {
                uaAddress = try! walletDb.getCurrentAddress(aid: Constants.ACCOUNT_ID)?.encode(params: Constants.PARAMS) ?? ""
            }.padding()
            
            StandardButton(label: "Parse address") {
                let ua = parseUnifiedAddress(address: uaAddress)
                tAddress = getTransparentAddress(ua: ua)
                sAddress = getSaplingAddress(ua: ua)
                oAddress = getOrchardAddress(ua: ua)
            }.padding()
            
            List{
                LabelTextRow(
                    label: "Transparent address",
                    text: tAddress
                ).padding()
                LabelTextRow(
                    label: "Sapling address",
                    text: sAddress
                ).padding()
                LabelTextRow(
                    label: "Orchard address",
                    text: oAddress
                ).padding()
            }
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
