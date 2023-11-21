import SwiftUI

struct TextCardView: View {
    var title: String
    var text: String
    
    var body: some View {
        GeometryReader { proxy in
            Spacer()
            Text(title)
        
            ScrollView {
                Text(text)
                    .fontWeight(.bold)
                    .font(.system(.title, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(minHeight: proxy.size.height)
            }
            
            Spacer()
        }
    }
    
    init(title: String, text: String) {
        self.text = text
        self.title = title
    }
}

#Preview {
    TextCardView(title: "Title", text: "Some example text")
}
