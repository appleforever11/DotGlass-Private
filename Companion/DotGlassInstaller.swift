import AppKit
import SwiftUI
import Sparkle

@main
struct DotGlassInstaller: App {
    @State private var status = "Installs only the personal Dot Glass widget. Marketplace Dot Glass and Codex Tracker are separate."
    private let updates = DotGlassUpdates()
    var body: some Scene {
        WindowGroup("Dot Glass Personal") {
            VStack(spacing: 20) {
                Image(systemName: "circle.circle.fill").font(.system(size: 70)).foregroundStyle(.purple.gradient)
                Text("Dot Glass Personal").font(.largeTitle.bold())
                Text(status).multilineTextAlignment(.center).foregroundStyle(.secondary)
                Button("Install / update personal widget") {
                    do { try install(); status = "Installed. Restart DockDoor Pro when convenient, then add Dot Glass Personal to your dock." }
                    catch { status = error.localizedDescription }
                }.buttonStyle(.borderedProminent)
                Button("Check for personal updates") { updates.check() }
                Text("Updates use the personal Sparkle feed. No marketplace files are changed.").font(.caption)
            }.padding(30).frame(width: 430, height: 340)
        }.windowResizability(.contentSize)
    }

    private func install() throws {
        let fm = FileManager.default
        guard let source = Bundle.main.resourceURL?.appendingPathComponent("DotGlassPersonal.bundle"),
              Bundle(url: source)?.bundleIdentifier == "dot-glass-personal" else { throw InstallError.invalidPayload }
        let folder = fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/DockDoorPro/Widgets")
        try fm.createDirectory(at: folder, withIntermediateDirectories: true)
        let target = folder.appendingPathComponent("DotGlassPersonal.bundle")
        if fm.fileExists(atPath: target.path) {
            guard let existing = Bundle(url: target), existing.bundleIdentifier == "dot-glass-personal" else { throw InstallError.wrongTarget }
            let installed = existing.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
            let incoming = Bundle(url: source)?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
            guard SUStandardVersionComparator.default.compareVersion(installed, toVersion: incoming) != .orderedDescending else { throw InstallError.olderPayload }
        }
        let staging = folder.appendingPathComponent(".dot-glass-\(UUID().uuidString).bundle")
        try fm.copyItem(at: source, to: staging)
        defer { try? fm.removeItem(at: staging) }
        if fm.fileExists(atPath: target.path) {
            let backupRoot = fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/DotGlassPersonal/Backups")
            try fm.createDirectory(at: backupRoot, withIntermediateDirectories: true)
            try fm.copyItem(at: target, to: backupRoot.appendingPathComponent("\(UUID().uuidString).bundle"))
            _ = try fm.replaceItemAt(target, withItemAt: staging)
        } else { try fm.moveItem(at: staging, to: target) }
    }
}

private enum InstallError: LocalizedError {
    case invalidPayload, wrongTarget, olderPayload
    var errorDescription: String? {
        switch self {
        case .invalidPayload: "The personal widget payload is missing or invalid."
        case .olderPayload: "A newer personal widget is already installed. Nothing was changed."
        case .wrongTarget: "Another widget occupies the personal install location. Nothing was changed."
        }
    }
}
