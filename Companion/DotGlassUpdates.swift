import AppKit
import Sparkle

@MainActor
final class DotGlassUpdates: NSObject {
    let controller = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
    private var started = false
    func check() {
        do {
            if !started { try controller.updater.start(); started = true }
            controller.checkForUpdates(nil)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
}
