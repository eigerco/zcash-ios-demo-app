import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack {
            NavigationLink {
                SpendingView()
            } label: {
                Text("Spend a note")
            }

            NavigationLink {
                TxDetailsView()
            } label: {
                Text("Explore transaction")
            }

            NavigationLink {
                EncodingView()
            } label: {
                Text("Decode Unified Address")
            }

            NavigationLink {
                TransparentBalanceView()
            } label: {
                Text("Get transparent balance")
            }
        }
    }
}

#Preview {
    MenuView()
}
