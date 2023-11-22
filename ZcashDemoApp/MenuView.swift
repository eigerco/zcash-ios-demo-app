import SwiftUI

struct MenuView: View {
    var body: some View {
        List {
            NavigationLink(destination: SpendingView()) {
                Text("Spend a note")
            }
            .buttonStyle(.bordered)
            .padding()

            NavigationLink(destination: TxDetailsView()) {
                Text("Explore transaction")
            }
            .buttonStyle(.bordered)
            .padding()

            NavigationLink(destination: EncodingView()) {
                Text("Decode Unified Address")
            }
            .buttonStyle(.bordered)
            .padding()

            NavigationLink(destination: TransparentBalanceView()) {
                Text("Get transparent balance")
            }
            .buttonStyle(.bordered)
            .padding()
        }.listStyle(PlainListStyle())
    }
}

#Preview {
    MenuView()
}
