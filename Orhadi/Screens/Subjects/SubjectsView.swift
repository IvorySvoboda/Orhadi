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
    @Environment(OrhadiTheme.self) private var theme
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @Query(
        sort: \Subject.startTime,
        animation: .smooth
    ) private var subjects: [Subject]

    @State private var showConfirmationDialog: Bool = false
    @State private var subjectToAdd: Subject?
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
                    SubjectListCell(subject: subject)
                }
            }
            .modifier(DefaultPlainList())
            .navigationTitle("Matérias")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    principalToolbar
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
            .overlay {
                overlay
            }
            .sheet(isPresented: $showConfirmationDialog) {
                confirmationSheet
            }
            .sheet(item: $subjectToAdd) { subject in
                SubjectSheetView(subject: subject, isNew: true)
                    .interactiveDismissDisabled()
            }
        }
    }

    private var principalToolbar: some View {
        ZStack {
            Text("Matérias")
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

    private var confirmationSheet: some View {
        VStack {
            Button {
                showConfirmationDialog = false
                subjectToAdd = Subject(isRecess: false)
            } label: {
                Text("Adicionar Matéria".uppercased())
                    .foregroundStyle(theme.bgColor())
                    .fontWeight(.semibold)
                    .frame(width: 370, height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.accentColor)
                    )
            }.buttonStyle(PlainButtonStyle())

            Button {
                showConfirmationDialog = false
                subjectToAdd = Subject(isRecess: true)
            } label: {
                Text("Adicionar Intervalo".uppercased())
                    .foregroundStyle(theme.bgColor())
                    .fontWeight(.semibold)
                    .frame(width: 370, height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.accentColor)
                    )
            }.buttonStyle(PlainButtonStyle())

            Divider()

            Button {
                showConfirmationDialog = false
            } label: {
                Text("Cancelar".uppercased())
                    .foregroundStyle(theme.bgColor())
                    .frame(width: 370, height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.accentColor)
                    )
            }.buttonStyle(PlainButtonStyle())
        }
        .offset(y: 15)
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(160)])
        .presentationBackground(theme.bgColor())
    }
}

#Preview("SubjectsView") {
    SubjectsView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
