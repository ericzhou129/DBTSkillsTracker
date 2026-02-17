import SwiftData
import Foundation

@Model
class SkillEntry {
    var skillName: String = ""
    var category: String = ""
    var timestamp: Date = Date()
    var notes: String = ""
    var trigger: String = ""
    var emotion: String = ""
    var urge: String = ""

    init(skillName: String, category: String, timestamp: Date = Date(), notes: String = "", trigger: String = "", emotion: String = "", urge: String = "") {
        self.skillName = skillName
        self.category = category
        self.timestamp = timestamp
        self.notes = notes
        self.trigger = trigger
        self.emotion = emotion
        self.urge = urge
    }
}
