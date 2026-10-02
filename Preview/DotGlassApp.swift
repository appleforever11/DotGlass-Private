import AppKit
import SwiftUI

@main
struct DotGlassApp: App {
    @NSApplicationDelegateAdaptor(DotGlassAppDelegate.self) private var delegate
    var body: some Scene {
        WindowGroup("Dot Glass") {
            if CommandLine.arguments.contains("--preview-tour") {
                DotTour(connection: .shared).frame(width: 440, height: 600)
            } else if #available(macOS 15.0, *) {
                DotPanel(dismiss: { NSApp.keyWindow?.close() }).frame(minWidth: 350, idealWidth: 440, minHeight: 500, idealHeight: 710).padding(8)
                    .containerBackground(.clear, for: .window)
            } else {
                DotPanel(dismiss: { NSApp.keyWindow?.close() }).frame(minWidth: 350, idealWidth: 440, minHeight: 500, idealHeight: 710).padding(8)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 448, height: 730)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Conversation") {
                Button("Show Connection") { DotConnection.shared.showConnection = true }
                    .keyboardShortcut("k", modifiers: [.command])
                Button("End Voice Session") { DotConnection.shared.stopAudio() }
                    .keyboardShortcut(".", modifiers: [.command])
            }
        }
    }
}

final class DotGlassAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if CommandLine.arguments.contains("--preview-tour") { DotConnection.shared.showTour = true; DotConnection.shared.needsSetup = false }
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    func applicationWillTerminate(_ notification: Notification) { DotConnection.shared.stopAudio() }
}
