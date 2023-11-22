import SwiftUI

struct TransparentBalanceView: View {
    @State var address = ""
    @State var balance: UInt64 = 0
    @State var isValid: Bool = false
    
    var body: some View {
        VStack {
            
            TextField("Transparent address", text: $address)
                .onChange(of: address) {
                    isValid = TransparentBalance.isValidTransparentAddress(address: address)
                }

            if (!isValid) {
                Text("The address given is invalid").foregroundStyle(.red)
            } else {
                LabelTextRow(label: "Balance", text: String(balance))
                AsyncButton(label: "Get address balance") {
                    balance = UInt64(await TransparentBalance.getBalanceFromTransparentAddress(address: address))
                }
            }

            StandardButton(label: "Paste test address") {
                address = "tmRecgPfjvzjaNAzFLHmyFzkTJNc6c1PJf8"
            }
        }
    }
}

#Preview {
    TransparentBalanceView()
}
