import SwiftUI

@main
struct FlowTonesApp: App {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var playerManager = PlayerManager()

    var body: some Scene {
        WindowGroup {
            ContentView(audioManager: audioManager, playerManager: playerManager)
        }
    }
}
