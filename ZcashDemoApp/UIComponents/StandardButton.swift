import Foundation
import SwiftUI

struct StandardButton: View {
    var action: () -> Void
    var label: String

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(label)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    init(label: String, action: @escaping () -> Void) {
        self.action = action
        self.label = label
    }
}

struct AsyncButton: View {
    var action: () async -> Void
    var label: String

    var body: some View {
        Button(action: {
            Task { await action() }
        }) {
            Text(label)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    init(label: String, action: @escaping () async -> Void) {
        self.action = action
        self.label = label
    }
}

#Preview {
    StandardButton(label: "label") {
        print("init")
    }
}
