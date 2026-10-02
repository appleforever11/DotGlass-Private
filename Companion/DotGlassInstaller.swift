import AppKit
import SwiftUI

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
        if fm.fileExists(atPath: target.path), Bundle(url: target)?.bundleIdentifier != "dot-glass-personal" { throw InstallError.wrongTarget }
        let staging = folder.appendingPathComponent(".dot-glass-\(UUID().uuidString).bundle")
        try fm.copyItem(at: source, to: staging)
        defer { try? fm.removeItem(at: staging) }
        if fm.fileExists(atPath: target.path) {
            _ = try fm.replaceItemAt(target, withItemAt: staging, backupItemName: "DotGlassPersonal-previous.bundle", options: .withoutDeletingBackupItem)
        } else { try fm.moveItem(at: staging, to: target) }
    }
}

private enum InstallError: LocalizedError {
    case invalidPayload, wrongTarget
    var errorDescription: String? {
        switch self {
        case .invalidPayload: "The personal widget payload is missing or invalid."
        case .wrongTarget: "Another widget occupies the personal install location. Nothing was changed."
        }
    }
}
