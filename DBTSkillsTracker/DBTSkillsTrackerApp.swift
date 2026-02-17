import SwiftUI
import SwiftData

@main
struct DBTSkillsTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SkillEntry.self)
    }
}
