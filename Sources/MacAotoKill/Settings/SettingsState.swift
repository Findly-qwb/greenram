import AppKit
import Foundation
import MacAotoKillCore

struct WhitelistAppInfo: Identifiable, Equatable {
    let bundleID: String
    let displayName: String
    let icon: NSImage
    let isDefaultSeed: Bool

    var id: String {
        bundleID
    }

    static func == (lhs: WhitelistAppInfo, rhs: WhitelistAppInfo) -> Bool {
        lhs.bundleID == rhs.bundleID
            && lhs.displayName == rhs.displayName
            && lhs.isDefaultSeed == rhs.isDefaultSeed
    }
}

struct IdleTimeAppInfo: Identifiable, Equatable {
    let bundleID: String
    let displayName: String
    let icon: NSImage

    var id: String {
        bundleID
    }

    static func == (lhs: IdleTimeAppInfo, rhs: IdleTimeAppInfo) -> Bool {
        lhs.bundleID == rhs.bundleID
            && lhs.displayName == rhs.displayName
    }
}

struct AutoQuitAppInfo: Identifiable, Equatable {
    let bundleID: String
    let displayName: String
    let icon: NSImage

    var id: String {
        bundleID
    }

    static func == (lhs: AutoQuitAppInfo, rhs: AutoQuitAppInfo) -> Bool {
        lhs.bundleID == rhs.bundleID
            && lhs.displayName == rhs.displayName
    }
}

struct MemoryLimitAppInfo: Identifiable, Equatable {
    let bundleID: String
    let displayName: String
    let icon: NSImage

    var id: String {
        bundleID
    }

    static func == (lhs: MemoryLimitAppInfo, rhs: MemoryLimitAppInfo) -> Bool {
        lhs.bundleID == rhs.bundleID
            && lhs.displayName == rhs.displayName
    }
}

struct AppDisplayInfo {
    let bundleID: String
    let displayName: String
    let icon: NSImage
}

struct SettingsState: Equatable {
    var memorySnapshot: SystemMemorySnapshot
    var languageCode: String
    var ramLimitPercent: Double
    var swapLimitEnabled: Bool
    var swapLimitGB: Double
    var minimumBackgroundMinutes: Double
    var automaticUpdateReminderEnabled: Bool
    var appVersion: String
    var autoQuitItems: [AutoQuitAppInfo]
    var appIdleTimeItems: [IdleTimeAppInfo]
    var appMemoryLimitItems: [MemoryLimitAppInfo]
    var whitelistItems: [WhitelistAppInfo]
    var newAutoQuitBundleID = ""
    var newIdleTimeBundleID = ""
    var newMemoryLimitBundleID = ""
    var newWhitelistBundleID = ""
    var isResetConfirmationPresented = false
    var blockedWhitelistedRuleBundleID: String?
}
