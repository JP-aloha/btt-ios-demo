//
//  MatricKitView.swift
//
//  Root view for the MatricKit tab — hosts the full MatricKitPoc feature set
//  (Dashboard, Metrics, Diagnostics, Triggers) behind a segmented switcher so
//  it nests inside the app's existing NavigationStack/TabView instead of
//  introducing a second, nested TabView.
//

import SwiftUI
import BlueTriangle

struct MatricKitView: View {
    enum Section: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case metrics = "Metrics"
        case diagnostics = "Error"
        case triggers = "Triggers"
        case hitchRate = "Hitch"

        var id: String { rawValue }
    }

    @State private var selectedSection: Section = .dashboard

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $selectedSection) {
                ForEach(Section.allCases) { section in
                    Text(section.rawValue).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 0)
            .padding(.vertical, 2)
            .background(Color(.secondarySystemBackground))

            Divider()

            Group {
                switch selectedSection {
                case .dashboard:
                    DashboardView()
                case .metrics:
                    MetricsListView()
                case .diagnostics:
                    DiagnosticsListView()
                case .triggers:
                    TriggersView()
                case .hitchRate:
                    HitchRateView()
                }
            }
        }
        .bttTrack("\(Self.self)")
    }
}

struct MatricKitView_Previews: PreviewProvider {
    static var previews: some View {
        MatricKitView()
            .environmentObject(MetricKitManager.shared)
    }
}
