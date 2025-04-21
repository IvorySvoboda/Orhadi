//
//  SubjectSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 20/04/25.
//

import SwiftUI

struct SubjectSheetView: View {
    @Environment(OrhadiTheme.self) private var theme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var navigationTitle: String {
        if isNew {
            return subject.isRecess ? "Novo Intervalo" : "Nova Matéria"
        } else {
            return "Editar \(subject.isRecess ? "Intervalo" : "Matéria")"
        }
    }

    @Bindable var subject: Subject
    var isNew: Bool

    var body: some View {
        NavigationStack {
            SubjectFormView(subject: subject)
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if isNew {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar", role: .cancel) {
                                dismiss()
                            }
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salvar") {
                            dismiss()

                            if isNew {
                                addItem()
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            } else {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            }
                        }.disabled(subject.name.isEmpty && !subject.isRecess)
                    }
                }
        }
    }

    private func addItem() {
        withAnimation {
            modelContext.insert(subject)
        }
    }
}

struct SubjectFormView: View {
    @Environment(OrhadiTheme.self) private var theme

    @Bindable var subject: Subject

    var body: some View {
        Form {
            if !subject.isRecess {
                subjectInfoSection
                teacherSelectionSection
            }

            timeSelectionSection
        }
        .modifier(DefaultList())
    }

    private var subjectInfoSection: some View {
        Section {
            HStack {
                Text("Nome")
                    .frame(width: 50, alignment: .leading)
                TextField("Minha nova matéria", text: $subject.name)
                    .autocorrectionDisabled()
            }
            HStack {
                Text("Local")
                    .frame(width: 50, alignment: .leading)
                TextField("Sala 101", text: $subject.place)
                    .autocorrectionDisabled()
            }
        } header: {
            Text("Matéria")
        }.listRowBackground(theme.secondaryBGColor())
    }

    private var teacherSelectionSection: some View {
        Section {
            NavigationLink {
                SubjectTeacherPickerView(subject: subject)
            } label: {
                HStack {
                    Text("Professor")
                    Spacer()
                    Text(subject.teacher?.name ?? "Nenhum")
                        .foregroundColor(.secondary)
                }
            }
        }.listRowBackground(theme.secondaryBGColor())
    }

    private var timeSelectionSection: some View {
        Section {
            CustomDayPickerView(date: $subject.schedule)

            HStack {
                Text("Das")

                Spacer()

                DatePicker("", selection: $subject.startTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()

                Text(" – ")

                DatePicker("", selection: $subject.endTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .onChange(of: subject.endTime) { _, newDate in
                        if newDate <= subject.startTime {
                            subject.endTime = subject.startTime + 60
                        }
                    }
            }
        } header: {
            Text("Horário")
        }.listRowBackground(theme.secondaryBGColor())
    }
}
