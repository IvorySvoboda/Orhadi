//
//  Subjects.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @Query(
        sort: [.init(\Subject.startTime, order: .forward)],
        animation: .bouncy
    )
    private var subjects: [Subject]

    @State private var showConfirmationDialog: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var subjectToEdit: Subject?
    @State private var isRecess: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(
        .weekday,
        from: Date()
    )
    @State private var scrollOffsetY: Int = 151

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    scrollOffsetY: $scrollOffsetY,
                    selectedDay: $selectedDay,
                    subjects: subjects,
                    dateExtractor: { $0.schedule }
                ) { subject in
                    SubjectListCell(
                        subject: subject,
                        subjectToEdit: $subjectToEdit
                    )
                }
            }
            .overlay {
                overlay
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .navigationTitle("Matérias")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Matérias")
                            .font(.headline)
                            .opacity(scrollOffsetY < 115 ? 1 : 0)
                            .offset(y: scrollOffsetY <= 70 ? -8 : 0)

                        Text(
                            Calendar.current.weekdaySymbols[selectedDay - 1]
                                .uppercased()
                        )
                        .foregroundStyle(Color.indigo)
                        .font(.caption)
                        .opacity(scrollOffsetY <= 70 ? 1 : 0)
                        .offset(y: scrollOffsetY <= 70 ? 8 : 14)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showConfirmationDialog.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme),
                for: .navigationBar
            )
            .confirmationDialog(
                "Adicionar",
                isPresented: $showConfirmationDialog
            ) {
                Button("Matéria") {
                    showAddSheet.toggle()
                }
                Button("Intervalo") {
                    isRecess = true
                    showAddSheet.toggle()
                }
                Button("Cancelar", role: .cancel) {}
            }
            .sheet(isPresented: $showAddSheet, onDismiss: {
                isRecess = false
            }) {
                SubjectAddView(isRecess: isRecess)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $subjectToEdit) { subject in
                SubjectEditView(subject: subject)
                    .interactiveDismissDisabled()
            }
        }
    }

    private var overlay: some View {
        Group {
            if subjects.filter({ Calendar.current.component(.weekday, from: $0.schedule) == selectedDay }).isEmpty && scrollOffsetY < 300 {
                ContentUnavailableView {
                    Label("Nenhuma Matéria", systemImage: "book")
                } description: {
                    Text("Nenhuma matéria hoje. Que tal aproveitar pra descansar um pouco?")
                }
            }
        }
    }
}

#Preview("SubjectsView") {
    SubjectsView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
