//
//  ErrorRcvLog.swift
//  Example-SwiftUI
//
//  Captures every request the BlueTriangle SDK sends to `err.rcv` so the
//  payload body (the same JSON the SDK prints to the Xcode console) can be
//  viewed and copied from inside the app.
//
//  The SDK uploads through its own `URLSession(configuration: .default)`, so
//  `URLProtocol.registerClass` would not see those requests. Instead we
//  swizzle `URLSessionConfiguration.default` to prepend a passive
//  `URLProtocol` that records the request and always returns `false` from
//  `canInit`, leaving the real upload untouched.
//

import Foundation
import ObjectiveC

struct ErrorRcvEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let errorType: String
    let message: String
    let body: String
    /// Which trigger produced this payload (from User → Generate Crash), or a
    /// detail pulled from the payload itself, e.g. "SIGSEGV" or "ANRWatchDog".
    let tag: String?

    var displayName: String {
        tag.map { "\(errorType) · \($0)" } ?? errorType
    }
}

final class ErrorRcvLog: ObservableObject {
    static let shared = ErrorRcvLog()

    @Published private(set) var entries: [ErrorRcvEntry] = []

    private let maxEntries = 100
    private let lock = NSLock()
    private var seenBodies = Set<Data>()
    private let fileURL: URL? = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask).first?
        .appendingPathComponent("error_rcv_log.json")
    private let pendingTagsURL: URL? = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask).first?
        .appendingPathComponent("error_rcv_pending_tags.json")

    private init() {
        entries = loadEntries()
    }

    /// Call once at launch, before `BlueTriangle.configure`.
    static func install() {
        URLSessionConfiguration.swizzleDefaultForErrorRcvCapture()
    }

    func clear() {
        lock.lock()
        seenBodies.removeAll()
        lock.unlock()
        entries = []
        saveEntries([])
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            entries.remove(at: index)
        }
        saveEntries(entries)
    }

    /// Remembers which trigger is about to fire, so the next payload of that
    /// error type is tagged with it — even when it's only uploaded after a
    /// crash and relaunch. Written synchronously so it survives the crash.
    func markPendingTrigger(errorType: String, tag: String) {
        lock.lock()
        defer { lock.unlock() }
        var tags = loadPendingTags()
        tags[errorType] = tag
        guard let pendingTagsURL, let data = try? JSONEncoder().encode(tags) else { return }
        try? data.write(to: pendingTagsURL, options: .atomic)
    }

    private func consumePendingTag(for errorType: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        var tags = loadPendingTags()
        guard let tag = tags.removeValue(forKey: errorType) else { return nil }
        if let pendingTagsURL, let data = try? JSONEncoder().encode(tags) {
            try? data.write(to: pendingTagsURL, options: .atomic)
        }
        return tag
    }

    private func loadPendingTags() -> [String: String] {
        guard let pendingTagsURL, let data = try? Data(contentsOf: pendingTagsURL) else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
    }

    /// Fallback tag for payloads no trigger was waiting for: the signal name
    /// in the message, else the `source` in NATIVEAPP.eMeta.
    private static func derivedTag(from report: [String: Any]?) -> String? {
        let message = report?["msg"] as? String ?? ""
        if let range = message.range(of: "SIG[A-Z]+", options: .regularExpression) {
            return String(message[range])
        }
        let eMeta = (report?["NATIVEAPP"] as? [String: Any])?["eMeta"] as? String ?? ""
        if let start = eMeta.range(of: "source: \"")?.upperBound,
           let end = eMeta[start...].firstIndex(of: "\"") {
            let source = String(eMeta[start..<end])
            return source.isEmpty ? nil : source
        }
        return nil
    }

    fileprivate func capture(_ request: URLRequest) {
        guard let url = request.url, url.path.contains("err.rcv"),
              let body = request.httpBody else { return }

        // canInit can be called more than once per request, and the SDK
        // retries failed uploads with the same body — record each body once.
        lock.lock()
        let isNew = seenBodies.insert(body).inserted
        lock.unlock()
        guard isNew else { return }

        let jsonData = Data(base64Encoded: body) ?? body
        let object = try? JSONSerialization.jsonObject(with: jsonData)
        let pretty = object
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: [.prettyPrinted]) }
            .flatMap { String(data: $0, encoding: .utf8) }
            ?? String(data: jsonData, encoding: .utf8)
            ?? ""

        let first = (object as? [[String: Any]])?.first ?? (object as? [String: Any])
        let errorType = first?["eTp"] as? String ?? "Error"
        let entry = ErrorRcvEntry(
            id: UUID(),
            date: Date(),
            errorType: errorType,
            message: first?["msg"] as? String ?? "",
            body: pretty,
            tag: consumePendingTag(for: errorType) ?? Self.derivedTag(from: first)
        )

        DispatchQueue.main.async {
            self.entries.insert(entry, at: 0)
            if self.entries.count > self.maxEntries {
                self.entries.removeLast(self.entries.count - self.maxEntries)
            }
            self.saveEntries(self.entries)
        }
    }

    private func loadEntries() -> [ErrorRcvEntry] {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([ErrorRcvEntry].self, from: data)) ?? []
    }

    private func saveEntries(_ entries: [ErrorRcvEntry]) {
        guard let fileURL else { return }
        DispatchQueue.global(qos: .utility).async {
            if let data = try? JSONEncoder().encode(entries) {
                try? data.write(to: fileURL, options: .atomic)
            }
        }
    }
}

// MARK: - Passive URLProtocol

private final class ErrorRcvSnifferProtocol: URLProtocol {
    override class func canInit(with task: URLSessionTask) -> Bool {
        if let request = task.originalRequest {
            ErrorRcvLog.shared.capture(request)
        }
        return false
    }

    override class func canInit(with request: URLRequest) -> Bool {
        ErrorRcvLog.shared.capture(request)
        return false
    }
}

// MARK: - URLSessionConfiguration swizzle

private extension URLSessionConfiguration {
    static var didSwizzleDefault = false

    static func swizzleDefaultForErrorRcvCapture() {
        guard !didSwizzleDefault else { return }
        didSwizzleDefault = true

        guard let original = class_getClassMethod(self, NSSelectorFromString("defaultSessionConfiguration")),
              let swizzled = class_getClassMethod(self, #selector(getter: errorRcvDefault)) else { return }
        method_exchangeImplementations(original, swizzled)
    }

    @objc class var errorRcvDefault: URLSessionConfiguration {
        // After the exchange this calls the original `.default` implementation.
        let configuration = self.errorRcvDefault
        configuration.protocolClasses = [ErrorRcvSnifferProtocol.self] + (configuration.protocolClasses ?? [])
        return configuration
    }
}
