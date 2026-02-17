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
                    .fixedSize()
                    .frame(minWidth: 68, alignment: .trailing)
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

                    if !entry.trigger.isEmpty || !entry.emotion.isEmpty || !entry.urge.isEmpty {
                        HStack(spacing: 8) {
                            if !entry.trigger.isEmpty {
                                Label(entry.trigger, systemImage: "bolt.fill")
                            }
                            if !entry.emotion.isEmpty {
                                Label(entry.emotion, systemImage: "heart.fill")
                            }
                            if !entry.urge.isEmpty {
                                Label(entry.urge, systemImage: "exclamationmark.triangle.fill")
                            }
                        }
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .padding(.top, 2)
                    }

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
    @State private var showingSkillPicker = false

    private var selectedCategory: SkillCategory? {
        SkillCategory(rawValue: entry.category)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Skill info section
                    sectionHeader("Skill")
                    VStack(spacing: 0) {
                        // Category - tappable to change
                        Button {
                            withAnimation { showingSkillPicker.toggle() }
                        } label: {
                            HStack {
                                Text("Category")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(selectedCategory?.displayName ?? entry.category)
                                    .font(.body)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 16)

                        // Skill name
                        HStack {
                            Text("Skill")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(entry.skillName)
                                .font(.body)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
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

                    // Context section
                    if let cat = SkillCategory(rawValue: entry.category) {
                        let config = SkillFieldConfig.config(for: cat)
                        if config.showTrigger || config.showEmotion || config.showUrge {
                            sectionHeader("Context")
                            VStack(spacing: 0) {
                                if config.showTrigger {
                                    TextField("What prompted this?", text: $entry.trigger)
                                        .font(.body)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                                if config.showTrigger && config.showEmotion {
                                    Divider().padding(.leading, 16)
                                }
                                if config.showEmotion {
                                    TextField("What were you feeling?", text: $entry.emotion)
                                        .font(.body)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                                if config.showEmotion && config.showUrge {
                                    Divider().padding(.leading, 16)
                                }
                                if config.showUrge {
                                    TextField("What urge were you resisting?", text: $entry.urge)
                                        .font(.body)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 16)
                        }
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
            .sheet(isPresented: $showingSkillPicker) {
                SkillPickerSheet(
                    selectedCategory: entry.category,
                    selectedSkill: entry.skillName
                ) { newCategory, newSkill in
                    entry.category = newCategory
                    entry.skillName = newSkill
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
}

// MARK: - Skill Picker Sheet

private struct SkillPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pickedCategory: SkillCategory?
    @State private var pickedSkill: String?
    let onSave: (String, String) -> Void

    init(selectedCategory: String, selectedSkill: String, onSave: @escaping (String, String) -> Void) {
        self.onSave = onSave
        _pickedCategory = State(initialValue: SkillCategory(rawValue: selectedCategory))
        _pickedSkill = State(initialValue: selectedSkill)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    sectionHeader("Category")
                    VStack(spacing: 0) {
                        ForEach(Array(SkillCategory.allCases.enumerated()), id: \.element) { index, category in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if pickedCategory != category {
                                        pickedCategory = category
                                        pickedSkill = nil
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(category.displayName).font(.body)
                                    Spacer()
                                    if pickedCategory == category {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)
                            }
                            .buttonStyle(.plain)
                            if index < SkillCategory.allCases.count - 1 {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 16)

                    if let cat = pickedCategory {
                        let skills = SkillCatalog.skills[cat] ?? []
                        sectionHeader("Skill")
                        VStack(spacing: 0) {
                            ForEach(Array(skills.enumerated()), id: \.element) { index, skill in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        pickedSkill = skill
                                    }
                                } label: {
                                    HStack {
                                        Text(skill).font(.body)
                                        Spacer()
                                        if pickedSkill == skill {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 13, weight: .bold))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 13)
                                }
                                .buttonStyle(.plain)
                                if index < skills.count - 1 {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Change Skill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let cat = pickedCategory, let skill = pickedSkill {
                            onSave(cat.rawValue, skill)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(pickedCategory == nil || pickedSkill == nil)
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
}
