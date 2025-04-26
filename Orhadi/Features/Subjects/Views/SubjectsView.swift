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
    @Environment(Settings.self) private var settings

    @Query(sort: \Subject.startTime, animation: .smooth) private var subjects: [Subject]
    @State private var viewModel = SubjectsViewModel()

    var body: some View {
        NavigationStack {
            List {
                WeekdayPickerBar(selectedDay: $viewModel.selectedDay)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { _, newY in
                                    viewModel.updateScrollOffset(with: newY)
                                }
                        }
                    )

                ForEach(viewModel.filteredSubjects) { subject in
                    SubjectRow(subject: subject,
                               subjectToAdd: $viewModel.subjectToAdd,
                               subjectToEdit: $viewModel.subjectToEdit)
                }
            }
            .orhadiPlainListStyle()
            .navigationTitle("Matérias")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    principalToolbar
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.toggleConfirmationDialog() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .overlay { overlay }
            .confirmationDialog("", isPresented: $viewModel.showConfirmationDialog) {
                ForEach([
                    (title: "Adicionar Matéria", isRecess: false),
                    (title: "Adicionar Intervalo", isRecess: true)
                ], id: \.title) { option in
                    Button(option.title) {
                        viewModel.toggleConfirmationDialog()
                        viewModel.prepareNewSubject(isRecess: option.isRecess)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            }
            .sheet(item: $viewModel.subjectToAdd) { subject in
                SubjectSheetView(subject: subject, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $viewModel.subjectToEdit) { subject in
                SubjectSheetView(subject: subject, isNew: false)
                    .interactiveDismissDisabled()
            }
        }
        .onAppear {
            viewModel.updateSubjects(subjects)
        }
        .onChange(of: subjects) { _, newSubjects in
            viewModel.updateSubjects(newSubjects)
        }
    }

    // MARK: - Toolbar

    private var principalToolbar: some View {
        ZStack {
            Text("Matérias")
                .font(.headline)
                .opacity(viewModel.scrollOffsetY < 115 ? 1 : 0)
                .offset(y: viewModel.scrollOffsetY <= 70 ? -8 : 0)

            Text(viewModel.titleForToolbar)
                .foregroundStyle(.tint)
                .font(.caption)
                .opacity(viewModel.scrollOffsetY <= 70 ? 1 : 0)
                .offset(y: viewModel.scrollOffsetY <= 70 ? 8 : 14)
        }
    }

    // MARK: - Overlay

    private var overlay: some View {
        Group {
            if viewModel.hasSubjectsToday && viewModel.scrollOffsetY < 300 {
                ContentUnavailableView {
                    Label("Nenhuma Matéria", systemImage: "book")
                } description: {
                    Text("Nenhuma matéria hoje. Que tal aproveitar pra descansar um pouco?")
                }
            }
        }
    }
}
