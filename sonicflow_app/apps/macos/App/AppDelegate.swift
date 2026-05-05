import SwiftUI

@main
struct SonicFlowMenuBarApp: App {
    @StateObject private var audioManager = MacAudioManager()

    var body: some Scene {
        MenuBarExtra {
            SonicFlowPopoverView(audioManager: audioManager)
        } label: {
            SonicFlowStatusIcon(isPlaying: audioManager.isPlaying)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SonicFlowSettingsView(audioManager: audioManager)
                .frame(width: 520, height: 520)
        }
    }
}

private struct SonicFlowStatusIcon: View {
    let isPlaying: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("MenuBarLeopard")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(.primary)
                .opacity(isPlaying ? 1 : 0.82)

            if isPlaying {
                Circle()
                    .fill(BrandTokens.Accent.success)
                    .frame(width: 6, height: 6)
                    .offset(x: 2, y: -1)
            }
        }
        .accessibilityLabel(isPlaying ? "SonicFlow playing" : "SonicFlow")
    }
}

private struct SonicFlowSettingsView: View {
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        TabView {
            Form {
                Picker("Popover", selection: $audioManager.preferences.popoverDensity) {
                    Text("Compact").tag(MacPopoverDensity.compact)
                    Text("Expanded").tag(MacPopoverDensity.expanded)
                }
                .pickerStyle(.segmented)

                Toggle("Show floating status", isOn: $audioManager.preferences.showFloatingStatus)
                Toggle("Open at login", isOn: $audioManager.preferences.openAtLogin)
                Toggle("Pause under meetings", isOn: $audioManager.preferences.respectMeetingAudio)

                LabeledContent("Current context") {
                    Text(audioManager.activeAudioContext.serviceName)
                        .foregroundStyle(.secondary)
                }

                Button("Refresh Audio Context") {
                    audioManager.refreshActiveAudioContext()
                }
            }
            .padding(24)
            .tabItem {
                Label("General", systemImage: "slider.horizontal.3")
            }

            Form {
                ForEach(audioManager.audioMixRules) { rule in
                    Section(rule.serviceName) {
                        Picker("Behavior", selection: Binding(
                            get: { rule.behavior },
                            set: { audioManager.updateMixRule(rule, behavior: $0) }
                        )) {
                            ForEach(AudioMixBehavior.allCases) { behavior in
                                Text(behavior.displayName).tag(behavior)
                            }
                        }

                        LabeledContent("App", value: rule.appName)
                        LabeledContent("Beat", value: "\(Int(rule.beatVolume * 100))%")
                        LabeledContent("App audio", value: "\(Int(rule.appVolume * 100))%")
                    }
                }
            }
            .padding(24)
            .tabItem {
                Label("Mixing", systemImage: "speaker.wave.2")
            }

            Form {
                Section("Favorites") {
                    if audioManager.favoriteExampleIDs.isEmpty {
                        Text("No favorites yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(MacSonicFlowExample.starterPack.filter { audioManager.favoriteExampleIDs.contains($0.id) }) { example in
                            Text(example.title)
                        }
                    }
                }

                Section("Recents") {
                    if audioManager.recentExamples.isEmpty {
                        Text("No recents yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(audioManager.recentExamples) { example in
                            Text(example.title)
                        }
                    }
                }
            }
            .padding(24)
            .tabItem {
                Label("Library", systemImage: "heart")
            }
        }
        .preferredColorScheme(.dark)
    }
}
