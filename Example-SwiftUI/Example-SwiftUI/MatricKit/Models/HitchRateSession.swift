import Foundation

/// A finalized hitch-rate monitoring session, persisted so past runs can be
/// reviewed later instead of vanishing once monitoring stops or the app quits.
struct HitchRateSession: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let frameCount: Int
    let hitchCount: Int
    let hitchTimeRatioMsPerSecond: Double

    var duration: TimeInterval { endDate.timeIntervalSince(startDate) }

    var hitchPercentage: Double {
        frameCount > 0 ? (Double(hitchCount) / Double(frameCount)) * 100 : 0
    }
}
