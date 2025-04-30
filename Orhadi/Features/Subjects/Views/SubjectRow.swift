//
//  SubjectRow.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct SubjectRow: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    @State private var showDeleteConfirmation = false

    var subject: Subject
    @Binding var subjectToAdd: Subject?
    @Binding var subjectToEdit: Subject?

    // MARK: - Views

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
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

                VStack(alignment: .leading, spacing: 2) {
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
            sendEmailSwipeAction
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteSwipeAction
            duplicateSwipeAction
            editSwipeAction
        }
        .alert(
            "Excluir \(subject.isRecess ? "intervalo" : "matéria")?",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                withAnimation {
                    context.delete(subject)
                }
            }
        } message: {
            Text("Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir \(subject.isRecess ? "este intervalo" : "esta matéria")?")
        }
    }

    // MARK: Swipe Actions

    private var sendEmailSwipeAction: some View {
        Group {
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
    }

    private var deleteSwipeAction: some View {
        Group {
            // Cria o botão adequado para as configurações do usuário
            if settings.subjectsDeleteConfirmation {
                Button {
                    showDeleteConfirmation.toggle()
                } label: {
                    Label("Excluir", systemImage: "trash.fill")
                        .labelStyle(.iconOnly)
                }
                .tint(.red)
            } else {
                Button(role: .destructive) {
                    subject.isDeleted = true
                    context.delete(subject)
                } label: {
                    Label("Excluir", systemImage: "trash.fill")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }

    private var duplicateSwipeAction: some View {
        Button {
            subjectToAdd = Subject(
                name: subject.name,
                teacher: subject.teacher,
                schedule: subject.schedule,
                startTime: subject.startTime + 1,
                endTime: subject.endTime + 1,
                place: subject.place,
                isRecess: subject.isRecess)
        } label: {
            Label("Duplicar", systemImage: "rectangle.fill.on.rectangle.angled.fill")
                .labelStyle(.iconOnly)
        }.tint(.teal)
    }

    private var editSwipeAction: some View {
        Button { subjectToEdit = subject } label: {
            Label("Editar", systemImage: "pencil")
                .labelStyle(.iconOnly)
        }.tint(.accentColor)
    }
}
