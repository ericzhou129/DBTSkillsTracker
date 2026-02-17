import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SkillEntry.timestamp, order: .reverse) private var entries: [SkillEntry]

    @State private var editingEntry: SkillEntry?

    var body: some View {
        Group {
            if entries.isEmpty {
                emptyState
            } else {
                entryList
            }
        }
        .sheet(item: $editingEntry) { entry in
            EditEntryView(entry: entry)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No entries yet")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            Text("Tap + to log a skill")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Entry List

    private var entryList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(groupedByDay, id: \.date) { group in
                    Section {
                        ForEach(group.entries) { entry in
                            entryRow(entry)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingEntry = entry
                                }
                        }
                    } header: {
                        dayHeader(for: group.date)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Day Header

    private func dayHeader(for date: Date) -> some View {
        HStack {
            Text(headerText(for: date))
                .font(.system(.caption, design: .default, weight: .semibold))
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 10)
        .background(Color(.systemBackground))
    }

    // MARK: - Row

    private func entryRow(_ entry: SkillEntry) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                // Time column
                Text(entry.timestamp, format: .dateTime.hour().minute())
                    .font(.system(.caption, design: .monospaced, weight: .regular))
                    .foregroundStyle(.tertiary)
                    .frame(width: 58, alignment: .trailing)
                    .padding(.top, 2)

                // Thin vertical line
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 0.5)
                    .padding(.vertical, -4)

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.skillName)
                        .font(.system(.body, design: .default, weight: .medium))
                        .foregroundStyle(.primary)

                    Text(SkillCategory(rawValue: entry.category)?.displayName ?? entry.category)
                        .font(.system(.caption2, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)

                    if !entry.notes.isEmpty {
                        Text(entry.notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                            .padding(.top, 2)
                    }
                }
                .padding(.vertical, 2)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Bottom separator
            Divider()
                .padding(.leading, 92)
        }
    }

    // MARK: - Helpers

    private struct DayGroup {
        let date: Date
        let entries: [SkillEntry]
    }

    private var groupedByDay: [DayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return grouped
            .map { DayGroup(date: $0.key, entries: $0.value) }
            .sorted { $0.date > $1.date }
    }

    private func headerText(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.wide).day().year())
        }
    }
}

// MARK: - Edit Entry View

private struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var entry: SkillEntry
    @State private var showingGuide = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Skill info section
                    sectionHeader("Skill")
                    VStack(spacing: 0) {
                        infoRow(label: "Name", value: entry.skillName)
                        Divider().padding(.leading, 16)
                        infoRow(label: "Category", value: SkillCategory(rawValue: entry.category)?.displayName ?? entry.category)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 16)

                    // Skill guide section
                    if let description = SkillDescriptions.descriptions[entry.skillName] {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingGuide.toggle()
                            }
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Quick Guide")
                                        .font(.body)
                                    Spacer()
                                    Image(systemName: showingGuide ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)

                                if showingGuide {
                                    Divider().padding(.leading, 16)
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    // Time section
                    sectionHeader("When")
                    VStack(spacing: 0) {
                        DatePicker("", selection: $entry.timestamp)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 16)

                    // Notes section
                    sectionHeader("Notes")
                    VStack(spacing: 0) {
                        TextField("Add notes...", text: $entry.notes, axis: .vertical)
                            .lineLimit(3...10)
                            .font(.body)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.medium)
                        .tint(.primary)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.system(.caption, design: .default, weight: .semibold))
                .tracking(1.0)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}
