import SwiftUI

struct DotPicker: View {
    @ObservedObject var connection: DotConnection
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var link = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Dots").font(.title2.bold())
                Spacer()
                Button("Done") { dismiss() }
            }
            Text("Choose a saved Dot, or add its ChatGPT conversation link.")
                .font(.callout).foregroundStyle(.secondary)
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(connection.directory.profiles) { profile in
                        Button {
                            connection.selectDot(profile); dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "circle.circle.fill").font(.title2).foregroundStyle(.blue)
                                Text(profile.name).font(.headline)
                                Spacer()
                                if profile.url == connection.conversation { Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue) }
                            }.padding(12).background(.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
                        }.buttonStyle(.plain).disabled(!connection.canSwitchDot)
                    }
                }
            }.frame(maxHeight: 220)
            if !connection.canSwitchDot {
                Text("Finish the call or pending message before switching Dots.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Divider()
            Text("Add a Dot").font(.headline)
            TextField("Name", text: $name).textFieldStyle(.roundedBorder)
            TextField("ChatGPT Dot conversation link", text: $link).textFieldStyle(.roundedBorder)
            Text("This saves a shortcut to an existing Dot. Create new Dots through ChatGPT when available.")
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                Button("Open ChatGPT") { connection.showConnection = true; dismiss() }
                Spacer()
                Button("Add and open") {
                    connection.addDot(url: link.trimmingCharacters(in: .whitespacesAndNewlines), name: name)
                    dismiss()
                }.buttonStyle(.borderedProminent)
                    .disabled(!connection.canSwitchDot || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || DotURLPolicy.conversation(link.trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
            }
        }.padding(24).frame(width: 380)
    }
}
