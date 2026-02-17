import Foundation

enum SkillCategory: String, CaseIterable, Codable {
    case coreMindfulness
    case interpersonalEffectiveness
    case emotionRegulation
    case distressTolerance
    case distressToleranceAddiction

    var displayName: String {
        switch self {
        case .coreMindfulness: return "Core Mindfulness"
        case .interpersonalEffectiveness: return "Interpersonal Effectiveness"
        case .emotionRegulation: return "Emotion Regulation"
        case .distressTolerance: return "Distress Tolerance"
        case .distressToleranceAddiction: return "DT - Addiction"
        }
    }

    var shortName: String {
        switch self {
        case .coreMindfulness: return "CM"
        case .interpersonalEffectiveness: return "IE"
        case .emotionRegulation: return "ER"
        case .distressTolerance: return "DT"
        case .distressToleranceAddiction: return "DT-A"
        }
    }
}

struct SkillCatalog {
    static let skills: [SkillCategory: [String]] = [
        .coreMindfulness: [
            "Wise Mind", "Observe", "Describe", "Participate",
            "Nonjudgmental Stance", "One-Mindfully", "Effectively",
            "Loving Kindness", "Balancing Doing Mind and Being Mind",
            "Walking the Middle Path", "Pros and Cons of Practicing Mindfulness",
            "Mindfulness of Pleasant Events"
        ],
        .interpersonalEffectiveness: [
            "DEAR MAN", "GIVE", "FAST", "Options for Intensity",
            "Pros and Cons of IE Skills", "Prioritizing Goals",
            "Troubleshooting IE Skills", "Finding and Getting People to Like You",
            "Ending Relationships", "Think and Act Dialectically",
            "Self-Validation", "Validating Others",
            "Changing Behavior with Reinforcement"
        ],
        .emotionRegulation: [
            "Identifying Primary Emotions", "Pros and Cons of Changing Emotions",
            "Check the Facts", "Opposite to Emotion Action", "Problem Solving",
            "Accumulating Positive Emotions (Short Term)",
            "Accumulating Positive Emotions (Long Term)", "Building Mastery",
            "Cope Ahead", "PLEASE Skills", "Nightmare Protocol", "Sleep Hygiene",
            "Mindfulness of Current Emotions", "Managing Extreme Emotions",
            "Troubleshooting ER Skills"
        ],
        .distressTolerance: [
            "STOP Skill", "Pros and Cons of DT Skills", "TIP Skills",
            "Distract with Wise Mind ACCEPTS", "IMPROVE the Moment",
            "Body Scan Meditation", "Sensory Awareness", "Radical Acceptance",
            "Turning the Mind", "Willingness", "Half-Smiling and Willing Hands",
            "Mindfulness of Current Thoughts"
        ],
        .distressToleranceAddiction: [
            "Reinforcing Non-Addictive Behaviors",
            "Burning Bridges and Building New Ones",
            "Alternate Rebellion", "Adaptive Denial"
        ]
    ]
}
