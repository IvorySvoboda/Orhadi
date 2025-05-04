//
//  Subjects.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @Environment(Settings.self) private var settings

    @Query(filter: #Predicate<Subject> {
        !$0.isSubjectDeleted
    }, sort: \Subject.startTime, animation: .smooth) private var subjects: [Subject]

    // MARK: - Properties

    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    @State private var showConfirmationDialog: Bool = false
    @State private var subjectToAdd: Subject? = nil
    @State private var subjectToEdit: Subject? = nil
    @State private var scrollOffsetY: Int = 151

    // MARK: - Computed Properties

    var isTodayEmpty: Bool {
        subjects.filter {
            Calendar.current.component(.weekday, from: $0.schedule) == selectedDay
        }.isEmpty
    }

    var toolbarTitle: String {
        Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                weekdayPickerBar

                ForEach(subjects.filter {
                    Calendar.current.component(.weekday, from: $0.schedule) == selectedDay
                }) { subject in
                    SubjectRow(
                        subject: subject,
                        onAdd: { subjectToAdd = subject },
                        onEdit: { subjectToEdit = subject }
                    )
                }
            }
            .orhadiPlainListStyle()
            .navigationTitle("Matérias")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Matérias")
                            .font(.headline)
                            .opacity(scrollOffsetY < 115 ? 1 : 0)
                            .offset(y: scrollOffsetY <= 60 ? -8 : 0)

                        Text(toolbarTitle)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .opacity(scrollOffsetY <= 60 ? 1 : 0)
                            .offset(y: scrollOffsetY <= 60 ? 8 : 14)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showConfirmationDialog.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .overlay { overlay }
            .confirmationDialog("", isPresented: $showConfirmationDialog) {
                ForEach([
                    (title: "Adicionar Matéria", isRecess: false),
                    (title: "Adicionar Intervalo", isRecess: true)
                ], id: \.title) { option in
                    Button(option.title) {
                        showConfirmationDialog.toggle()
                        subjectToAdd = Subject(isRecess: option.isRecess)
                    }
                }
                Button("Cancelar", role: .cancel) {}
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
    }

    private var weekdayPickerBar: some View {
        WeekdayPickerBar(selectedDay: $selectedDay)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _, newY in
                            withAnimation(.smooth(duration: 0.25)) {
                                scrollOffsetY = Int(newY)
                            }
                        }
                }
            )
    }

    private var overlay: some View {
        Group {
            if isTodayEmpty && scrollOffsetY < 300 {
                ContentUnavailableView {
                    Label("Nenhuma Matéria", systemImage: "book")
                } description: {
                    Text("Nenhuma matéria hoje. Que tal aproveitar pra descansar um pouco?")
                }
            }
        }
    }
}
