//
//  SubjectSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 20/04/25.
//

import SwiftData
import SwiftUI

struct SubjectSheetView: View {
   @Environment(OrhadiTheme.self) private var theme
   @Environment(\.modelContext) private var context
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

    // MARK: - Views

   var body: some View {
       NavigationStack {
           Form {
               if !subject.isRecess {
                   subjectInfoSection
                   teacherSelectionSection
               }
               timeSelectionSection
           }
           .modifier(DefaultList())
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

    private var subjectInfoSection: some View {
        Section {
            HStack {
                Text("Nome")
                    .frame(width: 50, alignment: .leading)
                TextField("Português", text: $subject.name)
                    .autocorrectionDisabled()
            }
            HStack {
                Text("Local")
                    .frame(width: 50, alignment: .leading)
                TextField("Sala 101", text: $subject.place)
                    .autocorrectionDisabled()
            }
        }.listRowBackground(theme.secondaryBGColor())
    }

    private var teacherSelectionSection: some View {
        Section {
            SubjectTeacherPickerView(subject: subject)
        }.listRowBackground(theme.secondaryBGColor())
    }

    private var timeSelectionSection: some View {
        Section {
            CustomDayPickerView(date: $subject.schedule)

            HStack {
                Text("Das")

                Spacer()

                DatePicker("Inicio", selection: $subject.startTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()

                Text(" – ")

                DatePicker("Fim", selection: $subject.endTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .onChange(of: subject.endTime) { _, newDate in
                        /// se a nova data for menor que a data de inicio, define `endTime` para `startTime + 60 (1 minuto)`
                        if newDate <= subject.startTime {
                            subject.endTime = subject.startTime + 60
                        }
                    }
            }
        } header: {
            Text("Horário")
        }.listRowBackground(theme.secondaryBGColor())
    }

    // MARK: - Functions

   private func addItem() {
       withAnimation {
           if !subject.isRecess {
               let existingSubjects = try? context.fetch(FetchDescriptor<Subject>(
                predicate: #Predicate { $0.name == subject.name }
               ))

               /// Se não tiver nenhuma matéria com o mesmo nome da matéria a ser adicionada,
               /// adiciona ele na Rotina de Estudos também.
               if let existingSubjects, existingSubjects.isEmpty {
                   context.insert(SRStudy(
                    name: subject.name,
                    studyDay: subject.schedule
                   ))
               }
           }

           context.insert(subject)
       }
   }
}
