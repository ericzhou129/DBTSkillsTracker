// Placeholder - to be implemented by agent
import SwiftData
import Foundation

@Model
class SkillEntry {
    var skillName: String = ""
    var category: String = ""
    var timestamp: Date = Date()
    var notes: String = ""

    init(skillName: String, category: String, timestamp: Date = Date(), notes: String = "") {
        self.skillName = skillName
        self.category = category
        self.timestamp = timestamp
        self.notes = notes
    }
}
