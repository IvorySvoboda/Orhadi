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

    enum SheetType: Identifiable {
        case add
        case edit(Subject)

        var id: String {
            switch self {
            case .add:
                return "add"
            case .edit(let subject):
                return subject.name
            }
        }
    }

    @Query(
        sort: [.init(\Subject.startTime, order: .forward)],
        animation: .bouncy
    )
    private var subjects: [Subject]

    @State private var showConfirmationDialog: Bool = false
    @State private var subjectToEdit: Subject?
    @State private var currentSheet: SheetType?
    @State private var isRecess: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(
        .weekday,
        from: Date()
    )
    @State private var minY: Int = 151

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    minY: $minY,
                    selectedDay: $selectedDay,
                    subjects: subjects,
                    dateExtractor: { $0.schedule }
                ) { subject in
                    AnyView(
                        SubjectListCell(
                            subject: subject,
                            currentSheet: $currentSheet)
                    )
                }
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .navigationTitle("Matérias")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Matérias")
                            .font(.headline)
                            .opacity(minY < 115 ? 1 : 0)
                            .offset(y: minY <= 70 ? -8 : 0)

                        Text(
                            Calendar.current.weekdaySymbols[selectedDay - 1]
                                .uppercased()
                        )
                        .foregroundStyle(Color.indigo)
                        .font(.caption)
                        .opacity(minY <= 70 ? 1 : 0)
                        .offset(y: minY <= 70 ? 8 : 14)
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
            .confirmationDialog(
                "Adicionar",
                isPresented: $showConfirmationDialog
            ) {
                Button("Matéria") {
                    currentSheet = .add
                }
                Button("Intervalo") {
                    isRecess = true
                    currentSheet = .add
                }
                Button("Cancelar", role: .cancel) {}
            }
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme),
                for: .navigationBar
            )
        }
        .sheet(
            item: $currentSheet,
            onDismiss: {
                isRecess = false
            }
        ) { sheetType in
            switch sheetType {
            case .add:
                SubjectAddView(isRecess: isRecess).interactiveDismissDisabled()
            case .edit(let subject):
                SubjectEditView(subject: subject).interactiveDismissDisabled()
            }
        }
    }
}

#Preview("SubjectsView") {
    SubjectsView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
