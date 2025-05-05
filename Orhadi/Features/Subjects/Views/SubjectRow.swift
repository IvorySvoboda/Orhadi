//
//  SubjectRow.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct SubjectRow: View, Equatable {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    var subject: Subject
    var onAdd: () -> Void
    var onEdit: () -> Void

    static func == (lhs: SubjectRow, rhs: SubjectRow) -> Bool {
        lhs.subject.id == rhs.subject.id
    }

    // MARK: - Views

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if subject.isRecess {
                HStack {
                    Text("INTERVALO")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                    CustomLabel("\(subject.startTime.formatToHour()) – \(subject.endTime.formatToHour())", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                }
            } else {
                Text(subject.name.nilIfEmpty() ?? String(localized: "Sem Nome"))
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
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            /// se existe um professor na matéria e o email do professor não está vazio
            /// crie o botão para enviar um email
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button {
                    subject.openMail()
                } label: {
                    Label("Enviar e-mail", systemImage: "envelope.fill")
                        .labelStyle(.iconOnly)
                }.tint(.accentColor)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    deleteSubject()
                }
            } label: {
                Label("Apagar", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }

            Button {
                onAdd()
            } label: {
                Label("Duplicar", systemImage: "rectangle.fill.on.rectangle.angled.fill")
                    .labelStyle(.iconOnly)
            }.tint(.teal)

            Button {
                onEdit()
            } label: {
                Label("Editar", systemImage: "pencil")
                    .labelStyle(.iconOnly)
            }.tint(.accentColor)
        }
        .contextMenu {
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button {
                    subject.openMail()
                } label: {
                    Label("Enviar e-mail", systemImage: "envelope.fill")
                }
            }

            Button {
                onEdit()
            } label: {
                Label("Editar", systemImage: "pencil")
            }

            Button {
                onAdd()
            } label: {
                Label("Duplicar", systemImage: "rectangle.fill.on.rectangle.angled.fill")
            }

            Button(role: .destructive) {
                Task {
                    deleteSubject()
                }
            } label: {
                Label("Apagar", systemImage: "trash.fill")
            }
        }
    }

    // MARK: - Actions

    private func deleteSubject() {
        withAnimation {
            subject.isSubjectDeleted = true
            subject.deletedAt = .now
        }
    }
}
