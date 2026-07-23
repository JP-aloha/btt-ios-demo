import SwiftUI

struct PayloadRow: View {
    let payload: StoredPayload
    var label: String? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let label {
                    Text(label)
                        .font(.headline)
                    Text(payload.timestampBegin.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(payload.timestampBegin.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                    Text("through \(payload.timestampEnd.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(payload.formattedSize)
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
