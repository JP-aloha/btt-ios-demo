//
//  MetricKitDiagnosticViewController.swift
//

import UIKit

final class MetricKitDiagnosticViewController: UIViewController {

    // MARK: - State

    private var cpuDuration: Double = 60
    private var hangDuration: Double = 8
    private var diskDuration: Double = 30

    private var slowLaunchDelay: Double = StressSimulators.savedSlowLaunchDelay
    private var slowLaunchCallSite: SlowLaunchCallSite = StressSimulators.savedSlowLaunchCallSite
    private var slowLaunchMethod: SlowLaunchMethod = StressSimulators.savedSlowLaunchMethod
    private var signpostActive = false

    private let signposts = SignpostLogger()

    // MARK: - Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let cpuCaption = MetricKitDiagnosticViewController.makeCaption()
    private let hangCaption = MetricKitDiagnosticViewController.makeCaption()
    private let diskCaption = MetricKitDiagnosticViewController.makeCaption()
    private let slowLaunchCaption = MetricKitDiagnosticViewController.makeCaption()
    private let slowLaunchDelayLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()
    private var statusSection: UIView?

    private lazy var crashButton = makeButton(title: "Trigger Test Crash", systemImage: "exclamationmark.triangle.fill", destructive: true) { [weak self] in
        self?.confirmCrash()
    }
    private lazy var cpuSpikeButton = makeButton(title: "Simulate CPU Spike", systemImage: "cpu") { [weak self] in
        self?.simulateCPUSpike()
    }
    private lazy var cpuBackgroundButton = makeButton(title: "Abuse CPU in Background", systemImage: "cpu.fill") { [weak self] in
        self?.abuseCPUInBackground()
    }
    private lazy var slowLaunchButton = makeButton(title: "Arm Slow Launch for Next Cold Launch", systemImage: "hare") { [weak self] in
        self?.armSlowLaunch()
    }
    private lazy var hangButton = makeButton(title: "Simulate Hang", systemImage: "hourglass") { [weak self] in
        self?.simulateHang()
    }
    private lazy var foreverHangButton = makeButton(title: "Simulate Forever Hang", systemImage: "infinity", destructive: true) { [weak self] in
        self?.confirmForeverHang()
    }
    private lazy var diskButton = makeButton(title: "Simulate Disk Writes", systemImage: "internaldrive") { [weak self] in
        self?.simulateDiskWrites()
    }
    private lazy var diskBackgroundButton = makeButton(title: "Abuse Disk in Background", systemImage: "internaldrive.fill") { [weak self] in
        self?.abuseDiskInBackground()
    }
    private lazy var networkButton = makeButton(title: "Simulate Network Transfer", systemImage: "network") { [weak self] in
        self?.simulateNetworkTransfer()
    }
    private lazy var signpostButton = makeButton(title: "Begin Signpost Interval", systemImage: "play.circle") { [weak self] in
        self?.toggleSignpost()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MetricKit Diagnostic"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
        ])

        buildSections()
        updateCaptions()
    }

    // MARK: - Sections

    private func buildSections() {
        contentStack.addArrangedSubview(makeSection(title: nil, rows: [makeWarningRow()]))

        contentStack.addArrangedSubview(makeSection(title: "1. Crash (crashDiagnostics)", rows: [crashButton]))

        contentStack.addArrangedSubview(makeSection(title: "2. Excess CPU Use (cpuMetrics / cpuExceptionDiagnostics)", rows: [
            makeSlider(value: cpuDuration, range: 10...120, step: 10) { [weak self] value in
                self?.cpuDuration = value
                self?.updateCaptions()
            },
            cpuCaption,
            cpuSpikeButton,
            Self.makeCaption("cpuExceptionDiagnostics specifically needs the OS to kill the app for CPU abuse while backgrounded — the button above (foreground only) can't produce it. Tap below, then immediately background the app (swipe up or press Home) and leave it for a minute or two."),
            cpuBackgroundButton,
        ]))

        contentStack.addArrangedSubview(makeSection(title: "3. Slow Launch (appLaunchDiagnostics, iOS 16+)", rows: [
            makeSegmentedControl(items: SlowLaunchCallSite.allCases.map(\.title),
                                 selectedIndex: SlowLaunchCallSite.allCases.firstIndex(of: slowLaunchCallSite) ?? 0) { [weak self] index in
                self?.slowLaunchCallSite = SlowLaunchCallSite.allCases[index]
                self?.updateCaptions()
            },
            makeSegmentedControl(items: SlowLaunchMethod.allCases.map(\.title),
                                 selectedIndex: SlowLaunchMethod.allCases.firstIndex(of: slowLaunchMethod) ?? 0) { [weak self] index in
                self?.slowLaunchMethod = SlowLaunchMethod.allCases[index]
                self?.updateCaptions()
            },
            slowLaunchDelayLabel,
            makeSlider(value: slowLaunchDelay, range: 1...25, step: 1) { [weak self] value in
                self?.slowLaunchDelay = value
                self?.updateCaptions()
            },
            slowLaunchCaption,
            slowLaunchButton,
        ]))

        contentStack.addArrangedSubview(makeSection(title: "4. Hang / App Responsiveness (applicationResponsivenessMetrics / hangDiagnostics)", rows: [
            makeSlider(value: hangDuration, range: 3...30, step: 1) { [weak self] value in
                self?.hangDuration = value
                self?.updateCaptions()
            },
            hangCaption,
            hangButton,
            foreverHangButton,
        ]))

        contentStack.addArrangedSubview(makeSection(title: "5. Excess Disk Write (diskIOMetrics / diskSpaceUsageMetrics / diskWriteExceptionDiagnostics)", rows: [
            makeSlider(value: diskDuration, range: 10...60, step: 5) { [weak self] value in
                self?.diskDuration = value
                self?.updateCaptions()
            },
            diskCaption,
            diskButton,
            Self.makeCaption("diskWriteExceptionDiagnostics is the disk equivalent of the CPU exception above — it needs the OS to kill the app for excessive writes while backgrounded. Tap below, then immediately background the app and leave it for a minute or two."),
            diskBackgroundButton,
        ]))

        contentStack.addArrangedSubview(makeSection(title: "Network Usage (networkTransferMetrics)", rows: [networkButton]))

        contentStack.addArrangedSubview(makeSection(title: "Custom Signpost (signpostMetrics)", rows: [signpostButton]))

        let status = makeSection(title: "Status", rows: [statusLabel])
        status.isHidden = true
        statusSection = status
        contentStack.addArrangedSubview(status)
    }

    private func updateCaptions() {
        cpuCaption.text = "Pin all cores near 100% for \(Int(cpuDuration))s. Real diagnostics need sustained load — try 60s+, and repeat across a couple of separate sessions."
        hangCaption.text = "Block main thread for \(Int(hangDuration))s. Real data shows longer hangs (15s+) tend to get watchdog-killed instead of producing a diagnostic — this range aims for \"severe enough to flag\" without crossing into a kill."
        diskCaption.text = "Continuously write 10 MB chunks for \(Int(diskDuration))s. Real diagnostics need a large total write volume, not just a few files."
        slowLaunchDelayLabel.text = "Delay: \(Int(slowLaunchDelay))s"
        slowLaunchCaption.text = "Next cold launch will be delayed from \(slowLaunchCallSite.title) using \(slowLaunchMethod.title). Real data shows launches up to ~16s only register as \"slow,\" not \"extended\" — stay in this range to test closer to that boundary without risking a launch-watchdog kill."
    }

    private func setStatus(_ message: String) {
        statusLabel.text = message
        guard let statusSection else { return }
        statusSection.isHidden = false
        view.layoutIfNeeded()
        scrollView.scrollRectToVisible(statusSection.convert(statusSection.bounds, to: scrollView), animated: true)
    }

    // MARK: - Actions

    private func confirmCrash() {
        let alert = UIAlertController(title: "Trigger a Test Crash?",
                                      message: "This force-quits the app so iOS can generate an MXCrashDiagnostic. Relaunch afterward and check the Diagnostics section, or tap Load Past Payloads in the Dashboard section.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Crash Now", style: .destructive) { _ in
            StressSimulators.triggerCrash()
        })
        present(alert, animated: true)
    }

    private func simulateCPUSpike() {
        let duration = cpuDuration
        setButton(cpuSpikeButton, title: "Spinning CPU…", enabled: false)
        StressSimulators.cpuSpin(duration: duration) { [weak self] in
            guard let self else { return }
            self.setButton(self.cpuSpikeButton, title: "Simulate CPU Spike", enabled: true)
            self.setStatus("CPU spike complete (\(Int(duration))s across all cores).")
        }
    }

    private func abuseCPUInBackground() {
        setButton(cpuBackgroundButton, title: "Running…", enabled: false)
        StressSimulators.cpuSpinInBackground { [weak self] elapsed in
            guard let self else { return }
            self.setButton(self.cpuBackgroundButton, title: "Abuse CPU in Background", enabled: true)
            self.setStatus("Background CPU abuse ran for \(Int(elapsed))s without being killed. If the app instead relaunched fresh when you reopened it, that's a stronger sign — check Diagnostics after the next batch window.")
        }
    }

    private func armSlowLaunch() {
        StressSimulators.armSlowLaunch(delay: slowLaunchDelay, callSite: slowLaunchCallSite, method: slowLaunchMethod)
        setStatus("Armed (\(slowLaunchCallSite.title) · \(slowLaunchMethod.title)). Force-quit the app now (swipe up in the app switcher) and relaunch by tapping the icon — the next cold launch will be slowed by \(Int(slowLaunchDelay))s.")
        setButton(slowLaunchButton, title: "Armed!", systemImage: "checkmark.circle.fill", enabled: false, tint: .systemGreen)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }
            self.setButton(self.slowLaunchButton, title: "Arm Slow Launch for Next Cold Launch", systemImage: "hare", enabled: true)
        }
    }

    private func simulateHang() {
        StressSimulators.hangMainThread(duration: hangDuration)
        setStatus("Simulated a \(Int(hangDuration))s main-thread hang.")
    }

    private func confirmForeverHang() {
        let alert = UIAlertController(title: "Hang Forever?",
                                      message: "This blocks the main thread indefinitely — the app will become fully unresponsive. You'll need to force-quit it (swipe up in the app switcher) to recover.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Hang Forever", style: .destructive) { _ in
            StressSimulators.hangMainThreadForever()
        })
        present(alert, animated: true)
    }

    private func simulateDiskWrites() {
        let duration = diskDuration
        setButton(diskButton, title: "Writing…", enabled: false)
        StressSimulators.diskChurn(duration: duration) { [weak self] in
            guard let self else { return }
            self.setButton(self.diskButton, title: "Simulate Disk Writes", enabled: true)
            self.setStatus("Disk write churn complete (\(Int(duration))s).")
        }
    }

    private func abuseDiskInBackground() {
        setButton(diskBackgroundButton, title: "Running…", enabled: false)
        StressSimulators.diskChurnInBackground { [weak self] elapsed in
            guard let self else { return }
            self.setButton(self.diskBackgroundButton, title: "Abuse Disk in Background", enabled: true)
            self.setStatus("Background disk abuse ran for \(Int(elapsed))s without being killed. If the app instead relaunched fresh when you reopened it, that's a stronger sign — check Diagnostics after the next batch window.")
        }
    }

    private func simulateNetworkTransfer() {
        setButton(networkButton, title: "Transferring…", enabled: false)
        StressSimulators.networkTransfer { [weak self] success in
            guard let self else { return }
            self.setButton(self.networkButton, title: "Simulate Network Transfer", enabled: true)
            self.setStatus(success ? "Network transfer complete." : "Network transfer failed.")
        }
    }

    private func toggleSignpost() {
        if signpostActive {
            signposts.end()
            setStatus("Ended signpost interval \"MatricKitPocInterval\".")
        } else {
            signposts.begin()
            setStatus("Began signpost interval \"MatricKitPocInterval\".")
        }
        signpostActive.toggle()
        setButton(signpostButton,
                  title: signpostActive ? "End Signpost Interval" : "Begin Signpost Interval",
                  systemImage: signpostActive ? "stop.circle" : "play.circle",
                  enabled: true)
    }

    // MARK: - View Builders

    private func makeSection(title: String?, rows: [UIView]) -> UIView {
        let card = UIStackView(arrangedSubviews: rows)
        card.axis = .vertical
        card.spacing = 12
        card.isLayoutMarginsRelativeArrangement = true
        card.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 10
        card.layer.cornerCurve = .continuous

        guard let title else { return card }

        let header = UILabel()
        header.text = title.uppercased()
        header.font = .preferredFont(forTextStyle: .footnote)
        header.textColor = .secondaryLabel
        header.numberOfLines = 0

        let headerContainer = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            header.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            header.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
        ])

        let section = UIStackView(arrangedSubviews: [headerContainer, card])
        section.axis = .vertical
        section.spacing = 6
        return section
    }

    private func makeWarningRow() -> UIView {
        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        icon.tintColor = .systemOrange
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let label = Self.makeCaption("Diagnostics (all except Crash) are suppressed while Xcode's debugger is attached. After installing, tap Stop in Xcode, then relaunch by tapping the app icon on the device itself — never via Xcode's Run button — before testing any trigger below.")
        label.textColor = .systemOrange

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.spacing = 10
        row.alignment = .top
        return row
    }

    private static func makeCaption(_ text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    private func makeButton(title: String,
                            systemImage: String,
                            destructive: Bool = false,
                            action: @escaping () -> Void) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: systemImage)
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)
        configuration.baseForegroundColor = destructive ? .systemRed : nil

        let button = UIButton(configuration: configuration, primaryAction: UIAction { _ in action() })
        button.contentHorizontalAlignment = .leading
        return button
    }

    private func setButton(_ button: UIButton,
                           title: String,
                           systemImage: String? = nil,
                           enabled: Bool,
                           tint: UIColor? = nil) {
        var configuration = button.configuration ?? .plain()
        configuration.title = title
        if let systemImage {
            configuration.image = UIImage(systemName: systemImage)
        }
        configuration.baseForegroundColor = tint
        button.configuration = configuration
        button.isEnabled = enabled
    }

    private func makeSlider(value: Double,
                            range: ClosedRange<Double>,
                            step: Double,
                            onChange: @escaping (Double) -> Void) -> UISlider {
        let slider = UISlider()
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        slider.value = Float(value)
        slider.addAction(UIAction { action in
            guard let slider = action.sender as? UISlider else { return }
            let snapped = (Double(slider.value) / step).rounded() * step
            slider.value = Float(snapped)
            onChange(snapped)
        }, for: .valueChanged)
        return slider
    }

    private func makeSegmentedControl(items: [String],
                                      selectedIndex: Int,
                                      onChange: @escaping (Int) -> Void) -> UISegmentedControl {
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selectedIndex
        control.addAction(UIAction { action in
            guard let control = action.sender as? UISegmentedControl else { return }
            onChange(control.selectedSegmentIndex)
        }, for: .valueChanged)
        return control
    }
}
