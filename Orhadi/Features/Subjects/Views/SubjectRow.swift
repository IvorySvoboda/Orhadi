//
//  SubjectRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 26/04/25.
//

import SwiftUI

struct SubjectRow: View {
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
                        intervalRow
                    } else {
                        subjectRow
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            /// se existe um professor na matéria e o email do professor não está vazio
            /// crie o botão para enviar um email
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button {
                    subject.openMail()
                } label: {
                    Label("Send e-mail", systemImage: "envelope.fill")
                        .labelStyle(.iconOnly)
                }.tint(.accentColor)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                subject.delete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }

            Button {
                onAdd()
            } label: {
                Label("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill")
                    .labelStyle(.iconOnly)
            }.tint(.teal)

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
                    .labelStyle(.iconOnly)
            }.tint(.accentColor)
        }
        .contextMenu {
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button {
                    subject.openMail()
                } label: {
                    Label("Send e-mail", systemImage: "envelope.fill")
                }
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                onAdd()
            } label: {
                Label("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill")
            }

            Button(role: .destructive) {
                subject.delete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
    
    private var intervalRow: some View {
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
    }
    
    private var subjectRow: some View {
        Group {
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
