import Foundation

/// Synthetic payloads shaped like real MXMetricPayload / MXDiagnosticPayload
/// dictionaryRepresentation() output. Apple doesn't allow constructing those
/// types directly, so this is the only way to preview the UI fully populated
/// before the OS has actually delivered anything.
enum SampleData {
    static func metricPayloadJSON(begin: Date, end: Date) -> Data {
        let object: [String: Any] = [
            "timeStampBegin": iso8601(begin),
            "timeStampEnd": iso8601(end),
            "appVersion": "1.0",
            "metaData": [
                "regionFormat": "US",
                "osVersion": "iPhone OS 17.0 (21A5248v)",
                "deviceType": "iPhone15,2",
                "appBuildVersion": "1",
            ],
            "cpuMetrics": ["cumulativeCPUTime": "12.4 kJ"],
            "gpuMetrics": ["cumulativeGPUTime": "3.1 kJ"],
            "memoryMetrics": ["peakMemoryUsage": "184.2 MB", "averageSuspendedMemory": "42.7 MB"],
            "diskIOMetrics": ["cumulativeLogicalWrites": "56.3 MB"],
            "displayMetrics": ["averagePixelLuminance": "38.5 APL"],
            "animationMetrics": ["scrollHitchTimeRatio": "1.2 ms per s"],
            "applicationTimeMetrics": [
                "cumulativeForegroundTime": "1832.0 s",
                "cumulativeBackgroundTime": "412.0 s",
            ],
            "applicationLaunchMetrics": ["histogrammedTimeToFirstDraw": "sample histogram"],
            "applicationResponsivenessMetrics": ["histogrammedAppHangTime": "sample histogram"],
            "applicationExitMetrics": [
                "foregroundExitData": ["cumulativeNormalAppExitCount": 3],
                "backgroundExitData": ["cumulativeMemoryResourceLimitExitCount": 1],
            ],
            "networkTransferMetrics": [
                "cumulativeWifiUpload": "0.8 MB",
                "cumulativeWifiDownload": "4.6 MB",
                "cumulativeCellularUpload": "0.1 MB",
                "cumulativeCellularDownload": "0.9 MB",
            ],
            "cellularConditionMetrics": ["cellularConditionTime": "sample histogram"],
            "locationActivityMetrics": ["cumulativeBestAccuracyTime": "0.0 s"],
            "diskSpaceUsageMetrics": [
                "totalBinaryFileSize": "42.0 MB",
                "totalDataFileSize": "18.5 MB",
                "totalCacheFolderSize": "6.2 MB",
                "totalDiskSpaceUsedSize": "66.7 MB",
                "totalDiskSpaceCapacity": "128.0 GB",
            ],
            "signpostMetrics": [
                [
                    "signpostCategory": "MatricKitPocDemo",
                    "signpostName": "MatricKitPocInterval",
                    "totalCount": 4,
                ]
            ],
        ]
        return jsonData(from: object)
    }

    /// One synthetic payload per diagnostic category (rather than bundling all
    /// five into a single payload) so "Load Sample Data" produces five distinct,
    /// separately-visible entries in the Diagnostics list.
    static func diagnosticSamples(begin: Date, end: Date) -> [(title: String, json: Data)] {
        [
            ("Crash", jsonData(from: [
                "timeStampBegin": iso8601(begin),
                "timeStampEnd": iso8601(end),
                "crashDiagnostics": [
                    [
                        "exceptionType": 1,
                        "exceptionCode": 0,
                        "signal": 6,
                        "terminationReason": "Namespace SIGNAL, Code 0x6",
                        "metaData": ["appBuildVersion": "1"],
                    ]
                ],
            ])),
            ("Hang", jsonData(from: [
                "timeStampBegin": iso8601(begin),
                "timeStampEnd": iso8601(end),
                "hangDiagnostics": [
                    [
                        "hangDuration": "2.3 s",
                        "metaData": ["appBuildVersion": "1"],
                    ]
                ],
            ])),
            ("Slow Launch", jsonData(from: [
                "timeStampBegin": iso8601(begin),
                "timeStampEnd": iso8601(end),
                "appLaunchDiagnostics": [
                    [
                        "launchDuration": "4.8 s",
                        "metaData": ["appBuildVersion": "1"],
                    ]
                ],
            ])),
            ("Excess CPU Use", jsonData(from: [
                "timeStampBegin": iso8601(begin),
                "timeStampEnd": iso8601(end),
                "cpuExceptionDiagnostics": [
                    [
                        "totalCPUTime": "5.1 kJ",
                        "totalSampledTime": "60.0 s",
                    ]
                ],
            ])),
            ("Excess Disk Write", jsonData(from: [
                "timeStampBegin": iso8601(begin),
                "timeStampEnd": iso8601(end),
                "diskWriteExceptionDiagnostics": [
                    [
                        "totalWritesCaused": "1.2 GB",
                    ]
                ],
            ])),
        ]
    }

    private static func jsonData(from object: [String: Any]) -> Data {
        (try? JSONSerialization.data(withJSONObject: object)) ?? Data("{}".utf8)
    }

    private static func iso8601(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}
