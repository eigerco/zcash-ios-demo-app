import SwiftUI

struct TextCardView: View {
    var title: String
    var text: String

    var body: some View {
        GeometryReader { proxy in
            Spacer()
            Text(title).font(.system(.title, design: .rounded))

            ScrollView {
                Text(text)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: proxy.size.height)
            }

            Spacer()
        }.padding()
    }

    init(title: String, text: String) {
        self.text = text
        self.title = title
    }
}

#Preview {
    TextCardView(title: "Title", text: "Some example text")
}
