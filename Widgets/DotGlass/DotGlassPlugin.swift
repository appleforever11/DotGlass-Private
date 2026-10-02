import DockDoorWidgetSDK
import SwiftUI

final class DotGlassPlugin: WidgetPlugin, DockDoorWidgetProvider {
    var id: String { "dot-glass-personal" }
    var name: String { "Dot Glass Personal" }
    var iconSymbol: String { "circle.circle" }
    var widgetDescription: String { "Your Dot in a glass conversation panel, with real messages and a voice-reactive ring." }
    var supportedOrientations: [WidgetOrientation] { [.horizontal, .vertical] }
    func settingsSchema() -> [WidgetSetting] {
        [.picker(key: "theme", label: "Orb glow", options: DotTheme.allCases.map(\.rawValue), defaultValue: "Arctic")]
    }
    @MainActor func makeBody(size: CGSize, isVertical: Bool) -> AnyView {
        AnyView(DotCompact(size: size, vertical: isVertical))
    }
    @MainActor func makePanelBody(dismiss: @escaping () -> Void) -> AnyView? { AnyView(DotPanel(dismiss: dismiss).frame(width: 440, height: 640)) }
}

struct DotCompact: View {
    let size: CGSize
    let vertical: Bool
    @ObservedObject private var connection = DotConnection.shared
    @AppStorage("widget.dot-glass-personal.theme") private var themeName = "Arctic"
    private var side: CGFloat { max(20, min(size.width, size.height)) }
    var body: some View {
        DotRing(phase: connection.phase, energy: connection.voiceLevel, diameter: side * 0.86)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dot Glass, \(themeName). \(connection.phase.rawValue). Open conversation panel.")
    }
}
