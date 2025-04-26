//
//  SRView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 31/03/25.
//

import SwiftData
import SwiftUI

struct StudyRoutineView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings
    @Environment(OrhadiTheme.self) private var theme

    @Query(sort: \SRStudy.name, animation: .smooth)
    private var studies: [SRStudy]

    @State private var studyToAdd: SRStudy?
    @State private var studyToEdit: SRStudy?
    @State private var showDeleteConfirmation: Bool = false
    @State private var studiesToStudy: [SRStudy] = []
    @State private var navigateToStudyingView: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    @State private var scrollOffsetY: Int = 151

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
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

                let filteredStudies = studies.filter {
                    Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay
                }

                ForEach(filteredStudies) { study in
                    SRRow(study: study,
                          studiesToStudy: $studiesToStudy,
                          navigateToStudyingView: $navigateToStudyingView,
                          studyToAdd: $studyToAdd,
                          studyToEdit: $studyToEdit)
                }
            }
            .modifier(DefaultPlainList())
            .navigationTitle("Rotina de Estudos")
            .overlay {
                overlay
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Rotina de Estudos")
                            .font(.headline)
                            .opacity(scrollOffsetY < 115 ? 1 : 0)
                            .offset(y: scrollOffsetY <= 70 ? -8 : 0)

                        Text(
                            Calendar.current.weekdaySymbols[selectedDay - 1]
                                .uppercased()
                        )
                        .foregroundStyle(.tint)
                        .font(.caption)
                        .opacity(scrollOffsetY <= 70 ? 1 : 0)
                        .offset(y: scrollOffsetY <= 70 ? 8 : 14)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        studyToAdd = SRStudy()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    let filteredstudies = studies.filter { $0.isForToday && !$0.hasStudiedThisWeek }
                    Button {
                        guard !filteredstudies.isEmpty else { return }
                        studiesToStudy = filteredstudies
                        navigateToStudyingView.toggle()
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }.disabled(filteredstudies.isEmpty)
                }
            }
            .navigationDestination(isPresented: $navigateToStudyingView) {
                StudyingView(studies: $studiesToStudy)
            }
            .sheet(item: $studyToAdd) { study in
                SRSheetView(study: study, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $studyToEdit) { study in
                SRSheetView(study: study, isNew: false)
                    .interactiveDismissDisabled()
            }
        }
    }

    private var overlay: some View {
        Group {
            if studies.filter({ Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay }).isEmpty && scrollOffsetY < 300 {
                ContentUnavailableView {
                    Label("Nenhuma Matéria", systemImage: "graduationcap")
                } description: {
                    Text("Nenhuma matéria hoje. Que tal aproveitar pra descansar um pouco?")
                }
            }
        }
    }
}

#Preview("SharedStudyRoutineView") {
    StudyRoutineView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}

struct SRRow: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    @State private var showDeleteConfirmation: Bool = false

    var study: SRStudy
    @Binding var studiesToStudy: [SRStudy]
    @Binding var navigateToStudyingView: Bool
    @Binding var studyToAdd: SRStudy?
    @Binding var studyToEdit: SRStudy?

    // MARK: - Views

    var body: some View {
        HStack {
            if study.hasStudiedThisWeek {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }

            Text(study.name.nilIfEmpty() ?? "Sem Nome")
                .lineLimit(1)
                .frame(maxWidth: 200, alignment: .leading)

            Spacer()

            Text(formatHourAndMinute(study.studyTime))
                .bold()
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            startStudySwipeAction
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteSwipeAction
            duplicateSwipeAction
            editSwipeAction
        }
        .alert("Deletar Estudo?", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Deletar", role: .destructive) {
                deleteStudy()
            }
        } message: {
            Text("Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir esta matéria dos estudos?")
        }
    }

    // MARK: Swipe Actions

    private var startStudySwipeAction: some View {
        Button(action: {
            studiesToStudy = [study]
            navigateToStudyingView.toggle()
        }) {
            Label("Iniciar", systemImage: "play.circle.fill")
        }.tint(.accentColor)
    }

    private var deleteSwipeAction: some View {
        Group {
            /// Cria o botão adequado para as configurações do usuário.
            if settings.studyDeleteConfirmation {
                Button {
                    showDeleteConfirmation.toggle()
                } label: {
                    Image(systemName: "trash.fill")
                }.tint(.red)
            } else {
                Button(role: .destructive) {
                    deleteStudy()
                } label: {
                    Image(systemName: "trash.fill")
                }
            }
        }
    }

    private var duplicateSwipeAction: some View {
        Button {
            studyToAdd = study
        } label: {
            Image(systemName: "rectangle.fill.on.rectangle.angled.fill")
        }.tint(.teal)
    }

    private var editSwipeAction: some View {
        Button {
            studyToEdit = study
        } label: {
            Image(systemName: "pencil")
        }.tint(.accentColor)
    }

    // MARK: - Functions

    private func deleteStudy() {
        withAnimation {
            context.delete(study)
        }
    }
}
