import SwiftUI
import SwiftData

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SkillEntry.timestamp, order: .reverse) private var entries: [SkillEntry]

    private var exportText: String {
        guard !entries.isEmpty else { return "" }

        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        let sortedDays = grouped.keys.sorted(by: >)

        var lines: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        for day in sortedDays {
            let dayEntries = grouped[day]!.sorted { $0.timestamp < $1.timestamp }
            lines.append(dateFormatter.string(from: day).uppercased())
            lines.append(String(repeating: "\u{2500}", count: 36))

            for entry in dayEntries {
                let time = timeFormatter.string(from: entry.timestamp)
                let cat = SkillCategory(rawValue: entry.category)?.displayName ?? entry.category
                lines.append("\(time)  \(entry.skillName) (\(cat))")

                if !entry.notes.isEmpty {
                    lines.append("         \(entry.notes)")
                }
            }

            lines.append("")
        }

        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if entries.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("Nothing to export")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Text("Log some skills first")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        Text(exportText)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                    }

                    Divider()

                    ShareLink(item: exportText) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .medium))
                            Text("Share")
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
