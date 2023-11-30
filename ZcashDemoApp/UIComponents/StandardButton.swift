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
    var action: () async throws  -> Void
    var label: String

    var body: some View {
        Button(action: {
            Task { try await action() }
        }) {
            Text(label)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    init(label: String, action: @escaping () async throws -> Void) {
        self.action = action
        self.label = label
    }
}

#Preview {
    StandardButton(label: "label") {
        print("init")
    }
}
