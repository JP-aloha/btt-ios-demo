import Foundation

struct FeatureDescriptor: Identifiable {
    let id = UUID()
    let number: Int
    /// Top-level JSON key this feature appears under in a payload's dictionaryRepresentation().
    let key: String
    let title: String
    let howToTrigger: String
}

/// The 5 MetricKit diagnostics and 14 MetricKit metrics, in the exact order
/// requested, each mapped to its real dictionaryRepresentation() JSON key
/// (verified against MetricKit.framework's headers).
enum FeatureCatalog {
    /// 5 diagnostics ("error-like" events): Crash, Excess CPU use, Slow Launch, Hang, Excess Disk write.
    static let diagnosticFeatures: [FeatureDescriptor] = [
        .init(number: 1, key: "crashDiagnostics", title: "Crash", howToTrigger: "Triggers section → Trigger Test Crash, then relaunch the app."),
        .init(number: 2, key: "cpuExceptionDiagnostics", title: "Excess CPU Use", howToTrigger: "Triggers section → Simulate CPU Spike repeatedly over time on a real device."),
        .init(number: 3, key: "appLaunchDiagnostics", title: "Slow Launch", howToTrigger: "Triggers section → Arm Slow Launch, then force-quit and relaunch the app. (iOS 16+)"),
        .init(number: 4, key: "hangDiagnostics", title: "Hang", howToTrigger: "Triggers section → Simulate Hang repeatedly; needs sustained real-device usage to surface."),
        .init(number: 5, key: "diskWriteExceptionDiagnostics", title: "Excess Disk Write", howToTrigger: "Triggers section → Simulate Disk Writes repeatedly over time on a real device."),
    ]

    /// 14 metrics, in the requested order.
    static let metricFeatures: [FeatureDescriptor] = [
        .init(number: 1, key: "applicationLaunchMetrics", title: "App Launch Performance", howToTrigger: "Force-quit and relaunch the app a few times."),
        .init(number: 2, key: "applicationResponsivenessMetrics", title: "App Responsiveness", howToTrigger: "Triggers section → Simulate Hang."),
        .init(number: 3, key: "animationMetrics", title: "Animation Smoothness", howToTrigger: "Scroll a list or navigate between screens."),
        .init(number: 4, key: "memoryMetrics", title: "Memory Usage", howToTrigger: "Peak/average memory accrues automatically from normal app use."),
        .init(number: 5, key: "cpuMetrics", title: "CPU Usage", howToTrigger: "Triggers section → Simulate CPU Spike, or just use the app normally."),
        .init(number: 6, key: "gpuMetrics", title: "GPU Usage", howToTrigger: "Scroll or navigate the UI; GPU time accrues automatically."),
        .init(number: 7, key: "diskIOMetrics", title: "Disk I/O Activity", howToTrigger: "Triggers section → Simulate Disk Writes."),
        .init(number: 8, key: "diskSpaceUsageMetrics", title: "Disk Space Usage", howToTrigger: "Computed as a daily on-device snapshot of the app's footprint. (iOS 26+)"),
        .init(number: 9, key: "networkTransferMetrics", title: "Network Usage", howToTrigger: "Triggers section → Simulate Network Transfer."),
        .init(number: 10, key: "cellularConditionMetrics", title: "Cellular Network Quality", howToTrigger: "Accrues automatically while connected over cellular."),
        .init(number: 11, key: "locationActivityMetrics", title: "Location Usage", howToTrigger: "Only populated if the app uses Core Location with active accuracy; not exercised by this POC."),
        .init(number: 12, key: "applicationTimeMetrics", title: "App Runtime", howToTrigger: "Foreground/background time accrues automatically as you use the app."),
        .init(number: 13, key: "applicationExitMetrics", title: "App Exit Reasons", howToTrigger: "Force-quit, background, or crash the app; exit reasons accrue over time."),
        .init(number: 14, key: "displayMetrics", title: "Display Power Usage", howToTrigger: "Accrues automatically while the screen is on and app is foregrounded."),
    ]
}
