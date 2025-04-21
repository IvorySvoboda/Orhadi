//
//  SubjectListCell.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftUI

struct SubjectListCell: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @State private var subjectToAdd: Subject?
    @State private var subjectToEdit: Subject?
    @State private var showConfirmation: Bool = false

    var subject: Subject

    // MARK: - Views

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            if subject.isRecess {
                HStack {
                    Text("INTERVALO")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(formatTime(subject.startTime)) – \(formatTime(subject.endTime))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                }
            } else {
                Text(subject.name.nilIfEmpty() ?? String(localized: "Sem Nome"))
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 2) {
                    if let teacher = subject.teacher {
                        if !teacher.name.isEmpty {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing, 1)
                                Text(teacher.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if !teacher.email.isEmpty {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing, -3)
                                Text(teacher.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .frame(maxWidth: 125, alignment: .leading)
                            }
                        }
                    }

                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(formatTime(subject.startTime)) – \(formatTime(subject.endTime))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if !subject.place.isEmpty {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(subject.place)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
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
        .alert("Excluir \(subject.isRecess ? String(localized: "intervalo") : String(localized: "matéria"))?",
               isPresented: $showConfirmation
        ) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                deleteSubject()
            }
        } message: {
            Text("Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir \(subject.isRecess ? String(localized: "este intervalo") : String(localized: "esta matéria"))?")
        }
        .sheet(item: $subjectToAdd) { subject in
            SubjectSheetView(subject: subject, isNew: true)
                .interactiveDismissDisabled()
        }
        .sheet(item: $subjectToEdit) { subject in
            SubjectSheetView(subject: subject, isNew: false)
                .interactiveDismissDisabled()
        }
    }

    private var deleteSwipeAction: some View {
        Group {
            if settings.subjectsDeleteConfirmation {
                Button(action: { showConfirmation.toggle() }) {
                    Image(systemName: "trash.fill")
                }.tint(.red)
            } else {
                Button(role: .destructive, action: deleteSubject) {
                    Image(systemName: "trash.fill")
                }
            }
        }
    }

    private var sendEmailSwipeAction: some View {
        Group {
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button(action: { openMail(to: teacher.email) }) {
                    Image(systemName: "envelope.fill")
                }.tint(.accentColor)
            }
        }
    }

    private var editSwipeAction: some View {
        Button(action: { subjectToEdit = subject }) {
            Image(systemName: "pencil")
        }.tint(.accentColor)
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
                isRecess: false)
        } label: {
            Image(systemName: "rectangle.fill.on.rectangle.angled.fill")
        }.tint(.teal)
    }

    // MARK: - Functions

    private func openMail(to email: String) {
        guard let encoded = subject.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "mailto:\(email)?subject=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }

    private func deleteSubject() {
        withAnimation(.bouncy) {
            modelContext.delete(subject)
        }
    }
}
