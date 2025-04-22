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

    @Query(sort: \SRSubject.name, animation: .smooth)
    private var subjects: [SRSubject]

    @State private var subjectToAdd: SRSubject?
    @State private var subjectToEdit: SRSubject?
    @State private var showDeleteConfirmation: Bool = false
    @State private var subjectsToStudy: [SRSubject] = []
    @State private var navigateToStudyingView: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    @State private var scrollOffsetY: Int = 151

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    scrollOffsetY: $scrollOffsetY,
                    selectedDay: $selectedDay,
                    subjects: subjects,
                    dateExtractor: { $0.studyDay }
                ) { subject in
                    SRRow(subject: subject,
                          subjectsToStudy: $subjectsToStudy,
                          navigateToStudyingView: $navigateToStudyingView,
                          subjectToAdd: $subjectToAdd,
                          subjectToEdit: $subjectToEdit)
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
                        subjectToAdd = SRSubject()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    let filteredSubjects = subjects.filter { $0.isForToday && !$0.hasStudiedThisWeek }
                    Button {
                        guard !filteredSubjects.isEmpty else { return }
                        subjectsToStudy = filteredSubjects
                        navigateToStudyingView.toggle()
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }.disabled(filteredSubjects.isEmpty)
                }
            }
            .navigationDestination(isPresented: $navigateToStudyingView) {
                StudyingView(subjects: $subjectsToStudy)
            }
            .sheet(item: $subjectToAdd) { subject in
                SRSheetView(subject: subject, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $subjectToEdit) { subject in
                SRSheetView(subject: subject, isNew: false)
                    .interactiveDismissDisabled()
            }
        }
    }

    private var overlay: some View {
        Group {
            if subjects.filter({ Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay }).isEmpty && scrollOffsetY < 300 {
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

    var subject: SRSubject
    @Binding var subjectsToStudy: [SRSubject]
    @Binding var navigateToStudyingView: Bool
    @Binding var subjectToAdd: SRSubject?
    @Binding var subjectToEdit: SRSubject?

    // MARK: - Views

    var body: some View {
        HStack {
            if subject.hasStudiedThisWeek {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }

            Text(subject.name.nilIfEmpty() ?? "Sem Nome")
                .lineLimit(1)
                .frame(maxWidth: 200, alignment: .leading)

            Spacer()

            Text(formatHourAndMinute(subject.studyTime))
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
                deleteSubject()
            }
        } message: {
            Text("Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir esta matéria dos estudos?")
        }
    }

    // MARK: Swipe Actions

    private var startStudySwipeAction: some View {
        Button(action: {
            subjectsToStudy = [subject]
            navigateToStudyingView.toggle()
        }) {
            Label("Iniciar", systemImage: "play.circle.fill")
        }.tint(.accentColor)
    }

    private var deleteSwipeAction: some View {
        Group {
            if settings.srSubjectsDeleteConfirmation {
                Button {
                    showDeleteConfirmation.toggle()
                } label: {
                    Image(systemName: "trash.fill")
                }
                .tint(.red)
            } else {
                Button(role: .destructive) {
                    deleteSubject()
                } label: {
                    Image(systemName: "trash.fill")
                }
            }
        }
    }

    private var duplicateSwipeAction: some View {
        Button {
            subjectToAdd = subject
        } label: {
            Image(systemName: "rectangle.fill.on.rectangle.angled.fill")
        }.tint(.teal)
    }

    private var editSwipeAction: some View {
        Button {
            subjectToEdit = subject
        } label: {
            Image(systemName: "pencil")
        }.tint(.accentColor)
    }

    // MARK: - Functions

    private func deleteSubject() {
        withAnimation {
            context.delete(subject)
        }
    }
}
