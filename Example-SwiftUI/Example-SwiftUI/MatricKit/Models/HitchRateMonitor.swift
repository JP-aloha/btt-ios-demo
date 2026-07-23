import Combine
import Foundation
import QuartzCore

/// Live hitch-rate monitoring for the MatricKit Hitch Rate section. The
/// actual frame-timing measurement lives in FramesTracker (a continuous,
/// app-wide, pull-only tracker); this class just snapshots FramesTracker's
/// counters and a CACurrentMediaTime() timestamp when a "session" starts,
/// then computes the delta plus the windowed hitch rate for that session's
/// timestamp range once, when the session ends — FramesTracker exposes no
/// callback, so there's nothing to update mid-session.
///
/// A shared singleton (like MetricKitManager) so monitoring state and saved
/// sessions survive switching away to another MatricKit section and back,
/// rather than being torn down with the view that started it.
final class HitchRateMonitor: ObservableObject {
    static let shared = HitchRateMonitor()

    @Published private(set) var isMonitoring = false
    @Published private(set) var frameCount = 0
    @Published private(set) var hitchCount = 0
    /// Milliseconds of hitch time per second observed, matching the unit
    /// convention MetricKit itself reports hitchTimeRatio in.
    @Published private(set) var hitchTimeRatioMsPerSecond: Double = 0
    @Published private(set) var sessions: [HitchRateSession] = []

    private let sessionsKey = "MatricKitPoc.HitchRateSessions"

    private var sessionStartTimestamp: CFTimeInterval?
    private var sessionStartDate: Date?
    private var startTotalFrameCount: UInt = 0
    private var startHitchFrameCount: UInt = 0

    private init() {
        loadSessions()
    }

    func start() {
        guard !isMonitoring else { return }
        FramesTracker.shared.start()

        sessionStartDate = Date()
        sessionStartTimestamp = CACurrentMediaTime()
        startTotalFrameCount = FramesTracker.shared.totalFrameCount
        startHitchFrameCount = FramesTracker.shared.slowFrameCount + FramesTracker.shared.frozenFrameCount
        frameCount = 0
        hitchCount = 0
        hitchTimeRatioMsPerSecond = 0
        isMonitoring = true
    }

    /// Stops monitoring, computes this session's stats in one shot, and
    /// archives them.
    @discardableResult
    func stopAndSaveSession() -> HitchRateSession? {
        defer {
            FramesTracker.shared.stop()
            isMonitoring = false
            sessionStartDate = nil
            sessionStartTimestamp = nil
        }

        guard let sessionStartTimestamp, let start = sessionStartDate else {
            return nil
        }

        frameCount = Int(FramesTracker.shared.totalFrameCount - startTotalFrameCount)
        hitchCount = Int((FramesTracker.shared.slowFrameCount + FramesTracker.shared.frozenFrameCount) - startHitchFrameCount)
        hitchTimeRatioMsPerSecond = FramesTracker.shared.hitchRate(from: sessionStartTimestamp, to: CACurrentMediaTime())

        guard frameCount > 0 else { return nil }

        let session = HitchRateSession(
            id: UUID(),
            startDate: start,
            endDate: Date(),
            frameCount: frameCount,
            hitchCount: hitchCount,
            hitchTimeRatioMsPerSecond: hitchTimeRatioMsPerSecond
        )
        sessions.insert(session, at: 0)
        saveSessions()
        return session
    }

    func clearSessions() {
        sessions.removeAll()
        saveSessions()
    }

    func deleteSessions(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        saveSessions()
    }

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey),
              let decoded = try? JSONDecoder().decode([HitchRateSession].self, from: data) else {
            return
        }
        sessions = decoded
    }

    private func saveSessions() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: sessionsKey)
    }
}
