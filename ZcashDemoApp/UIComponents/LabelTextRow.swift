import SwiftUI

struct LabelTextRow: View {
    var label: String
    var text: String

    var body: some View {
        HStack {
            Text(label)
            Text(text)
        }
    }

    init(label: String, text: String) {
        self.label = label
        self.text = text
    }
}

#Preview {
    LabelTextRow(label: "Example", text: "text")
}
