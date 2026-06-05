import Foundation

public struct EventLogEntry: Equatable {
    public let date: Date
    public let message: String

    public init(date: Date, message: String) {
        self.date = date
        self.message = message
    }

    public var menuTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return "\(formatter.string(from: date))  \(message)"
    }
}

public protocol EventLogging: AnyObject {
    func append(_ message: String)
}

public final class EventLog: EventLogging {
    private var entries: [EventLogEntry] = []
    private let limit: Int
    private let retentionInterval: TimeInterval
    private let fileURL: URL?

    public init(
        limit: Int = 5_000,
        retentionInterval: TimeInterval = 3 * 24 * 60 * 60,
        fileURL: URL? = EventLog.defaultFileURL()
    ) {
        self.limit = limit
        self.retentionInterval = retentionInterval
        self.fileURL = fileURL
        self.entries = Self.loadEntries(from: fileURL)
        if pruneEntries(now: Date()) {
            persistEntries()
        }
    }

    public func append(_ message: String) {
        append(message, at: Date())
    }

    public func append(_ message: String, at date: Date) {
        entries.append(EventLogEntry(date: date, message: message))
        _ = pruneEntries(now: date)
        persistEntries()
    }

    public func recentEntries(limit: Int) -> [EventLogEntry] {
        if pruneEntries(now: Date()) {
            persistEntries()
        }
        return Array(entries.suffix(limit).reversed())
    }

    public func exportText(now: Date = Date()) -> String {
        if pruneEntries(now: now) {
            persistEntries()
        }

        var lines = [
            "GreenRAM Logs",
            "Generated: \(Self.timestampString(for: now))",
            "Retention: last 3 days",
            ""
        ]
        lines.append(contentsOf: entries.map(Self.logLine(for:)))
        return lines.joined(separator: "\n") + "\n"
    }

    public func export(to url: URL, now: Date = Date()) throws {
        let text = exportText(now: now)
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func pruneEntries(now: Date) -> Bool {
        let originalEntries = entries
        let cutoff = now.addingTimeInterval(-retentionInterval)
        entries = entries.filter { $0.date >= cutoff }
        if entries.count > limit {
            entries.removeFirst(entries.count - limit)
        }
        return entries != originalEntries
    }

    private func persistEntries() {
        guard let fileURL else { return }
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let text = entries.map(Self.logLine(for:)).joined(separator: "\n")
            try (text + (text.isEmpty ? "" : "\n")).write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            // Logging must never block memory protection behavior.
        }
    }

    private static func loadEntries(from fileURL: URL?) -> [EventLogEntry] {
        guard
            let fileURL,
            let text = try? String(contentsOf: fileURL, encoding: .utf8)
        else {
            return []
        }

        return text
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { parseLine(String($0)) }
    }

    private static func logLine(for entry: EventLogEntry) -> String {
        "\(timestampString(for: entry.date))\t\(sanitize(entry.message))"
    }

    private static func parseLine(_ line: String) -> EventLogEntry? {
        guard let separator = line.firstIndex(of: "\t") else { return nil }
        let timestamp = String(line[..<separator])
        let messageStart = line.index(after: separator)
        let message = String(line[messageStart...])
        guard let date = timestampFormatter().date(from: timestamp) else { return nil }
        return EventLogEntry(date: date, message: message)
    }

    private static func sanitize(_ message: String) -> String {
        message
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
    }

    private static func timestampString(for date: Date) -> String {
        timestampFormatter().string(from: date)
    }

    private static func timestampFormatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    public static func defaultFileURL() -> URL? {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(AppIdentity.name, isDirectory: true)
            .appendingPathComponent("events.log", isDirectory: false)
    }
}
