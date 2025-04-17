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

    @State private var showConfirmation: Bool = false

    var subject: Subject
    @Binding var currentSheet: SubjectsView.SheetType?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            if subject.isRecess {
                HStack {
                    Text("INTERVALO")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(
                        "\(formatTime(subject.startTime)) – \(formatTime(subject.endTime))"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                }
            } else {
                Text(
                    subject.name.isEmpty
                        ? String(localized: "Sem Nome") : subject.name
                )
                .font(.headline)
                .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 2) {
                    if let teacher = subject.teacher {
                        if !teacher.name.isEmpty {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 1)
                                Text(teacher.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if !teacher.email.isEmpty {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, -3)
                                Text(teacher.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .frame(maxWidth: 125, alignment: .leading)
                            }
                        }
                    }

                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(
                            "\(formatTime(subject.startTime)) – \(formatTime(subject.endTime))"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    if !subject.place.isEmpty {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(subject.place)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button(action: {
                    let name = subject.name.isEmpty ? "Sem Nome" : subject.name
                    let subjectEncoded =
                    name.addingPercentEncoding(
                        withAllowedCharacters: .urlQueryAllowed
                    ) ?? ""
                    
                    if let url = URL(
                        string:
                            "mailto:\(teacher.email)?subject=\(subjectEncoded)"
                    ) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "envelope.fill")
                }.tint(.accentColor)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if settings.subjectsDeleteConfirmation {
                Button(action: {
                    showConfirmation.toggle()
                }) {
                    Image(systemName: "trash.fill")
                }.tint(.red)
            }
            if !settings.subjectsDeleteConfirmation {
                Button(
                    role: .destructive,
                    action: {
                        deleteSubject(subject: subject)
                    }
                ) {
                    Image(systemName: "trash.fill")
                }
            }

            Button(action: { currentSheet = .edit(subject) }) {
                Image(systemName: "pencil")
            }.tint(.accentColor)
        }
        .alert(
            "Excluir \(subject.isRecess ? String(localized: "intervalo") : String(localized: "matéria"))?",
            isPresented: $showConfirmation
        ) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                deleteSubject(subject: subject)
            }
        } message: {
            Text(
                "Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir \(subject.isRecess ? String(localized: "este intervalo") : String(localized: "esta matéria"))?"
            )
        }
    }

    private func deleteSubject(subject: Subject) {
        withAnimation(.bouncy) {
            modelContext.delete(subject)
        }
    }
}
