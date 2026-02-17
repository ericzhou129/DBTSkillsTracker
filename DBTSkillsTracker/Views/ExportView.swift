import SwiftUI
import SwiftData

enum ExportType: String, CaseIterable {
    case detailed = "Detailed Log"
    case tracker = "Tracker"
}

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SkillEntry.timestamp, order: .forward) private var allEntries: [SkillEntry]

    @State private var sinceDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
    @State private var exportType: ExportType = .detailed

    private var filteredEntries: [SkillEntry] {
        allEntries.filter { $0.timestamp >= Calendar.current.startOfDay(for: sinceDate) }
    }

    private var currentCSV: String {
        switch exportType {
        case .detailed: return detailedCSV
        case .tracker: return trackerCSV
        }
    }

    private var currentFilename: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: Date())
        switch exportType {
        case .detailed: return "dbt-detailed-log-\(dateStr).csv"
        case .tracker: return "dbt-tracker-summary-\(dateStr).csv"
        }
    }

    private func csvFileURL() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(currentFilename)
        try? currentCSV.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // CSV escape helper
    private func esc(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }

    // MARK: - Detailed CSV
    private var detailedCSV: String {
        var lines: [String] = ["Date,Time,Category,Skill,Trigger,Emotion,Urge,Notes"]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm"

        for entry in filteredEntries {
            let cat = SkillCategory(rawValue: entry.category)?.displayName ?? entry.category
            let row = [
                df.string(from: entry.timestamp),
                tf.string(from: entry.timestamp),
                esc(cat),
                esc(entry.skillName),
                esc(entry.trigger),
                esc(entry.emotion),
                esc(entry.urge),
                esc(entry.notes)
            ].joined(separator: ",")
            lines.append(row)
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Tracker CSV
    private var trackerCSV: String {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: sinceDate)
        let endDay = calendar.startOfDay(for: .now)

        // Build date columns
        var dates: [Date] = []
        var current = startDay
        while current <= endDay {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        // Build lookup set: "skillName|dateString"
        var usedSet: Set<String> = []
        for entry in filteredEntries {
            let dayStr = df.string(from: calendar.startOfDay(for: entry.timestamp))
            usedSet.insert("\(entry.skillName)|\(dayStr)")
        }

        // Header
        let dateHeaders = dates.map { df.string(from: $0) }
        var lines: [String] = ["Category,Skill," + dateHeaders.joined(separator: ",")]

        // Rows by category
        for category in SkillCategory.allCases {
            let skills = SkillCatalog.skills[category] ?? []
            for skill in skills {
                var cells = [esc(category.displayName), esc(skill)]
                for date in dates {
                    let key = "\(skill)|\(df.string(from: date))"
                    cells.append(usedSet.contains(key) ? "Yes" : "")
                }
                lines.append(cells.joined(separator: ","))
            }
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date picker and segment control
                VStack(spacing: 16) {
                    HStack {
                        Text("Since")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Spacer()
                        DatePicker("", selection: $sinceDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    .padding(.horizontal, 20)

                    Picker("Export Type", selection: $exportType) {
                        ForEach(ExportType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 12)

                Divider()

                // Preview
                if filteredEntries.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("No entries in this range")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Text("Try an earlier date")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                } else {
                    ScrollView([.horizontal, .vertical]) {
                        Text(currentCSV)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.primary)
                            .padding(16)
                    }

                    Divider()

                    // Share button
                    ShareLink(item: csvFileURL()) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .medium))
                            Text("Share CSV")
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
