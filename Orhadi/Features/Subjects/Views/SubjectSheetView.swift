//
//  SubjectSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 20/04/25.
//

import SwiftData
import SwiftUI

struct SubjectSheetView: View {
   @Environment(\.modelContext) private var context
   @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var teacher: Teacher?
    @State private var schedule: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var place: String
    @State private var isRecess: Bool

   @Bindable var subject: Subject
   var isNew: Bool

    private var navigationTitle: String {
        if isNew {
            return subject.isRecess ? "Novo Intervalo" : "Nova Matéria"
        } else {
            return "Editar \(subject.isRecess ? "Intervalo" : "Matéria")"
        }
    }

    // MARK: - INIT

    init(subject: Subject, isNew: Bool) {
        self.subject = subject
        self.isNew = isNew

        _name = State(initialValue: subject.name)
        _teacher = State(initialValue: subject.teacher)
        _schedule = State(initialValue: subject.schedule)
        _startTime = State(initialValue: subject.startTime)
        _endTime = State(initialValue: subject.endTime)
        _place = State(initialValue: subject.place)
        _isRecess = State(initialValue: subject.isRecess)
    }

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
           .orhadiListStyle()
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
                           subject.name = name
                           subject.teacher = teacher
                           subject.schedule = schedule
                           subject.startTime = startTime
                           subject.endTime = endTime
                           subject.place = place
                           UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                       }
                   }.disabled(name.isEmpty && !isRecess)
               }
           }
       }
   }

    private var subjectInfoSection: some View {
        Section {
            HStack {
                Text("Nome")
                    .frame(width: 50, alignment: .leading)
                TextField("Português", text: $name)
                    .autocorrectionDisabled()
            }
            HStack {
                Text("Local")
                    .frame(width: 50, alignment: .leading)
                TextField("Sala 101", text: $place)
                    .autocorrectionDisabled()
            }
        }.listRowBackground(Color.orhadiSecondaryBG)
    }

    private var teacherSelectionSection: some View {
        Section {
            TeacherPickerView(teacher: $teacher)
        }.listRowBackground(Color.orhadiSecondaryBG)
    }

    private var timeSelectionSection: some View {
        Section {
            CustomDayPickerView(date: $schedule)

            HStack {
                Text("Das")

                Spacer()

                DatePicker("Inicio", selection: $startTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()

                Text(" – ")

                DatePicker("Fim", selection: $endTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .onChange(of: endTime) { _, newDate in
                        /// se a nova data for menor que a data de inicio, define `endTime` para `startTime + 60 (1 minuto)`
                        if newDate <= startTime {
                            endTime = startTime + 60
                        }
                    }
            }
        } header: {
            Text("Horário")
        }.listRowBackground(Color.orhadiSecondaryBG)
    }

    // MARK: - Functions

   private func addItem() {
       withAnimation {
           if !isRecess {
               let existingSubjects = try? context.fetch(FetchDescriptor<Subject>(predicate: #Predicate {
                   $0.name == name
               }))

               /// Se não tiver nenhuma matéria com o mesmo nome da matéria a ser adicionada,
               /// adiciona ele na Rotina de Estudos também.
               if let existingSubjects, existingSubjects.isEmpty {
                   context.insert(SRStudy(
                    name: name,
                    studyDay: schedule
                   ))
               }
           }

           context.insert(Subject(
            name: name,
            teacher: teacher,
            schedule: schedule,
            startTime: startTime,
            endTime: endTime,
            place: place,
            isRecess: isRecess
           ))
       }
   }
}
