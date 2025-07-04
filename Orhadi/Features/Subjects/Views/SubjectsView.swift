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
    @State private var showConfirmationDialog: Bool = false /// iOS 18
    @State private var showConfirmation: Bool = false /// iOS 26+
    @State private var subjectToAdd: Subject?
    @State private var subjectToEdit: Subject?
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
                if #available(iOS 26, *) {
                    weekdayPickerBar
                        .opacity(scrollOffsetY < 5 ? 0 : 1)
                } else {
                    weekdayPickerBar
                }

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
                        if #available(iOS 26.0, *) {
                            Text("Matérias")
                                .font(.headline)
                                .opacity(scrollOffsetY < 53 ? 1 : 0)
                                .blur(radius: scrollOffsetY < 53 ? 0 : 3)
                                .offset(y: scrollOffsetY <= 5 ? -8 : scrollOffsetY < 53 ? 0 : 14)

                            Text(toolbarTitle)
                                .foregroundStyle(.tint)
                                .font(.caption)
                                .opacity(scrollOffsetY <= 5 ? 1 : 0)
                                .blur(radius: scrollOffsetY <= 5 ? 0 : 3)
                                .offset(y: scrollOffsetY <= 5 ? 8 : 14)
                        } else {
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
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if #available(iOS 26, *) {
                            showConfirmation.toggle()
                        } else {
                            showConfirmationDialog.toggle()
                        }
                    } label: {
                        if #available(iOS 26, *) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .overlay { overlay }
            .confirmationDialog("Adicionar", isPresented: $showConfirmationDialog) {
                ForEach([
                    (title: "Adicionar Matéria", isRecess: false),
                    (title: "Adicionar Intervalo", isRecess: true)
                ], id: \.title) { option in
                    Button(option.title) {
                        showConfirmationDialog.toggle()
                        subjectToAdd = Subject(isRecess: option.isRecess)
                    }
                }
            }
            .sheet(item: $subjectToAdd) { subject in
                SubjectSheetView(subject: subject, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $subjectToEdit) { subject in
                SubjectSheetView(subject: subject, isNew: false)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showConfirmation) {
                VStack {
                    VStack(spacing: 10) {
                        Button {
                            showConfirmation.toggle()
                            subjectToAdd = Subject(isRecess: false)
                        } label: {
                            Capsule()
                                .fill(Color.accentColor)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .overlay {
                                    Text("Adicionar Matéria".uppercased())
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.orhadiSecondaryForeground)
                                }
                        }

                        Button {
                            showConfirmation.toggle()
                            subjectToAdd = Subject(isRecess: true)
                        } label: {
                            Capsule()
                                .fill(Color.accentColor)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .overlay {
                                    Text("Adicionar Intervalo".uppercased())
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.orhadiSecondaryForeground)
                                }
                        }
                    }
                    .offset(y: 15)
                }
                .padding()
                .presentationDetents([.height(135)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var weekdayPickerBar: some View {
        WeekdayPickerBar(selectedDay: $selectedDay)
            .background {
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _, newY in
                            if #available(iOS 26, *) {
                                DispatchQueue.main.async {
                                    withAnimation(.smooth(duration: 0.5)) {
                                        scrollOffsetY = Int(newY)
                                    }
                                }
                            } else {
                                withAnimation(.smooth(duration: 0.25)) {
                                    scrollOffsetY = Int(newY)
                                }
                            }
                        }
                }
            }
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
