import XCTest
@testable import MacAotoKillCore

final class EventLogTests: XCTestCase {
    func testPersistsAndPrunesEventsOutsideRetentionWindow() throws {
        let fileURL = temporaryLogURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        let now = Date()
        let oldDate = now.addingTimeInterval(-4 * 24 * 60 * 60)
        let recentDate = now.addingTimeInterval(-2 * 24 * 60 * 60)

        let log = EventLog(limit: 10, fileURL: fileURL)
        log.append("old event", at: oldDate)
        log.append("recent event", at: recentDate)
        log.append("current event", at: now)

        let reloadedLog = EventLog(limit: 10, fileURL: fileURL)
        let messages = reloadedLog.recentEntries(limit: 10).map(\.message)

        XCTAssertEqual(messages, ["current event", "recent event"])
    }

    func testExportTextContainsRecentEvents() {
        let now = Date()
        let log = EventLog(limit: 10, fileURL: nil)

        log.append("settings updated", at: now)

        let text = log.exportText(now: now)

        XCTAssertTrue(text.contains("GreenRAM Logs"))
        XCTAssertTrue(text.contains("Retention: last 3 days"))
        XCTAssertTrue(text.contains("settings updated"))
    }

    private func temporaryLogURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("GreenRAMTests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("events.log", isDirectory: false)
    }
}
