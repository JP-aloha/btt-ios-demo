import SwiftUI
import BlueTriangle
import UIKit

struct RawJSONView: View {
    let payload: StoredPayload
    @State private var didCopy = false

    var body: some View {
        ScrollView {
            Text(payload.prettyJSON)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Raw JSON")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    UIPasteboard.general.string = payload.prettyJSON
                    didCopy = true
                } label: {
                    Label("Copy", systemImage: didCopy ? "checkmark" : "doc.on.doc")
                }
            }
        }
        .bttTrack("\(Self.self)")
    }
}
