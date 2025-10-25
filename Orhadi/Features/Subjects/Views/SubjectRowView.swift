//
//  SubjectRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/04/25.
//

import SwiftUI

struct SubjectRowView: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    var subject: Subject
    var onAdd: () -> Void
    var onEdit: () -> Void

    // MARK: - Views

    var body: some View {
        TimelineView(.everyMinute) { _ in
            HStack(spacing: 5) {

                if subject.isOngoing && settings.showCurrentSubjectIndicator {
                    RoundedRectangle(cornerRadius: 3, style: .circular)
                        .fill(Color.cyan)
                        .frame(width: 5)
                        .frame(maxHeight: .infinity)
                }

                VStack(alignment: .leading, spacing: 5) {
                    if subject.isRecess {
                        HStack {
                            Text("Interval")
                                .textCase(.uppercase)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                            CustomLabel("\(subject.startTime.formatToHour()) – \(subject.endTime.formatToHour())", systemImage: "clock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                        }
                    } else {
                        Text(subject.name.nilIfEmpty() ?? String(localized: "No Name"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .frame(maxWidth: 200, alignment: .leading)

                        VStack(alignment: .leading, spacing: 3) {
                            if let teacher = subject.teacher {
                                if !teacher.name.isEmpty {
                                    CustomLabel("\(teacher.name)", systemImage: "person.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if !teacher.email.isEmpty {
                                    CustomLabel("\(teacher.email)", systemImage: "envelope.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            CustomLabel("\(subject.startTime.formatToHour()) – \(subject.endTime.formatToHour())", systemImage: "clock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if !subject.place.isEmpty {
                                CustomLabel("\(subject.place)", systemImage: "building.2.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            /// se existe um professor na matéria e o email do professor não está vazio
            /// crie o botão para enviar um email
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button("Send e-mail", systemImage: "envelope.fill") {
                    subject.openMail()
                }.tint(.accentColor)
            }
        }
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                try? subject.softDelete(in: context)
            }

            Button("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill") {
                onAdd()
            }.tint(.teal)

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }.tint(.accentColor)
        }
        .contextMenu {
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button("Send e-mail", systemImage: "envelope.fill") {
                    subject.openMail()
                }
            }

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }

            Button("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill") {
                onAdd()
            }

            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                try? subject.softDelete(in: context)
            }
        }
    }
}
