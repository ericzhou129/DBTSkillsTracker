import SwiftUI
import SwiftData

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedCategory: SkillCategory?
    @State private var selectedSkill: String?
    @State private var date: Date = .now
    @State private var notes: String = ""
    @State private var expandedSkillInfo: String?
    @State private var trigger: String = ""
    @State private var emotion: String = ""
    @State private var urge: String = ""

    private var canSave: Bool {
        selectedCategory != nil && selectedSkill != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    categorySection
                    if let selectedCategory {
                        skillSection(for: selectedCategory)
                    }
                    if selectedSkill != nil {
                        dateSection
                        if let selectedCategory {
                            let config = SkillFieldConfig.config(for: selectedCategory)
                            if config.showTrigger || config.showEmotion || config.showUrge {
                                contextSection(config: config)
                            }
                        }
                        notesSection
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Log Skill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
    }

    // MARK: - Category Selection

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Category")

            VStack(spacing: 0) {
                ForEach(Array(SkillCategory.allCases.enumerated()), id: \.element) { index, category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                            selectedSkill = nil
                            trigger = ""
                            emotion = ""
                            urge = ""
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(category.displayName)
                                .font(.body)

                            Spacer()

                            if selectedCategory == category {
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
        }
    }

    // MARK: - Skill Selection

    private func skillSection(for category: SkillCategory) -> some View {
        let skills = SkillCatalog.skills[category] ?? []
        return VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Skill")

            VStack(spacing: 0) {
                ForEach(Array(skills.enumerated()), id: \.element) { index, skill in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            // Skill select button
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedSkill = skill
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Text(skill)
                                        .font(.body)

                                    Spacer()

                                    if selectedSkill == skill {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                                .padding(.leading, 16)
                                .padding(.vertical, 13)
                            }
                            .buttonStyle(.plain)

                            // Info button
                            if SkillDescriptions.descriptions[skill] != nil {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        expandedSkillInfo = expandedSkillInfo == skill ? nil : skill
                                    }
                                } label: {
                                    Image(systemName: expandedSkillInfo == skill ? "info.circle.fill" : "info.circle")
                                        .font(.system(size: 15))
                                        .foregroundStyle(expandedSkillInfo == skill ? .primary : .tertiary)
                                        .frame(width: 44, height: 44)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Spacer().frame(width: 16)
                            }
                        }

                        // Expandable description
                        if expandedSkillInfo == skill,
                           let description = SkillDescriptions.descriptions[skill] {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

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

    // MARK: - Date & Notes

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("When")

            VStack(spacing: 0) {
                DatePicker("", selection: $date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Notes")

            VStack(spacing: 0) {
                TextField("What prompted this? How did it help?", text: $notes, axis: .vertical)
                    .lineLimit(3...10)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)

            Text("Optional")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 32)
                .padding(.top, 6)
        }
    }

    // MARK: - Context Fields

    private func contextSection(config: SkillFieldConfig) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Context")

            VStack(spacing: 0) {
                if config.showTrigger {
                    TextField("What prompted this?", text: $trigger)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                if config.showTrigger && config.showEmotion {
                    Divider().padding(.leading, 16)
                }
                if config.showEmotion {
                    TextField("What were you feeling?", text: $emotion)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                if config.showEmotion && config.showUrge {
                    Divider().padding(.leading, 16)
                }
                if config.showUrge {
                    TextField("What urge were you resisting?", text: $urge)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)

            Text("Optional")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 32)
                .padding(.top, 6)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(.caption, design: .default, weight: .semibold))
            .tracking(1.0)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }

    private func save() {
        guard let selectedCategory, let selectedSkill else { return }
        let entry = SkillEntry(
            skillName: selectedSkill,
            category: selectedCategory.rawValue,
            timestamp: date,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            trigger: trigger.trimmingCharacters(in: .whitespacesAndNewlines),
            emotion: emotion.trimmingCharacters(in: .whitespacesAndNewlines),
            urge: urge.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(entry)
        dismiss()
    }
}
