//
//  Subjects.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/03/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct SubjectsView: View {
    @Namespace private var animation
    @State private var viewModel: ViewModel

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                WeekdayPickerBar(selectedDay: $viewModel.selectedDay)
                    .opacity(viewModel.showSelectedWeekday ? 0 : 1)

                ForEach(viewModel.filteredSubjects) { subject in
                    SubjectRowView(
                        subject: subject,
                        onAdd: { viewModel.subjectToAdd = subject },
                        onEdit: { viewModel.subjectToEdit = subject }
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("Subjects")
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y
            }, action: { _, scrollOffset in
                viewModel.handleScrollGeoChange(scrollOffset)
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Subjects")
                            .font(.headline)
                            .frame(height: 30)
                            .opacity(viewModel.showTitle ? 1 : 0)
                            .blur(radius: viewModel.showTitle ? 0 : 3)
                            .offset(y: viewModel.showSelectedWeekday ? -8 : viewModel.showTitle ? 0 : 14)

                        Text(viewModel.toolbarTitle)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .frame(height: 30)
                            .opacity(viewModel.showSelectedWeekday ? 1 : 0)
                            .blur(radius: viewModel.showSelectedWeekday ? 0 : 3)
                            .offset(y: viewModel.showSelectedWeekday ? 8 : 14)
                    }
                }

                if #available(iOS 26, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add", systemImage: "plus") {
                            viewModel.showConfirmation.toggle()
                        }.tint(.accentColor)
                    }.matchedTransitionSource(id: "Add", in: animation)
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add", systemImage: "plus") {
                            viewModel.showConfirmation.toggle()
                        }.tint(.accentColor)
                    }
                }
            }
            .overlay {
                if viewModel.filteredSubjects.isEmpty, !viewModel.hideOverlay {
                    ContentUnavailableView {
                        Label("No Subjects", systemImage: "book")
                    } description: {
                        Text("No subjects today. How about taking some time to rest a little?")
                    }
                }
            }
            .sheet(item: $viewModel.subjectToAdd) { subject in
                SubjectSheetView(subject: subject, isNew: true, context: viewModel.context)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $viewModel.subjectToEdit) { subject in
                SubjectSheetView(subject: subject, isNew: false, context: viewModel.context)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $viewModel.showConfirmation) {
                subjectAddOptions
            }
            .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
                viewModel.fetchSubjects()
            }
        }
    }

    private var subjectAddOptions: some View {
        VStack {
            VStack(spacing: 10) {
                ForEach([
                    (title: String(localized: "Add Subject"), isRecess: false),
                    (title: String(localized: "Add Interval"), isRecess: true)
                ], id: \.title) { option in
                    Button {
                        viewModel.showConfirmation.toggle()
                        viewModel.subjectToAdd = Subject(
                            schedule: Calendar.current.date(bySetting: .weekday, value: viewModel.selectedDay, of: Date(timeIntervalSince1970: 0))!,
                            isRecess: option.isRecess)
                    } label: {
                        let buttonText = Text(option.title)
                            .textCase(.uppercase)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.orhadiSecondaryForeground)

                        if #available(iOS 26, *) {
                            Capsule()
                                .fill(Color.accentColor)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .overlay { buttonText }
                        } else {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color.accentColor)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .overlay { buttonText }
                        }
                    }
                }
            }.offset(y: 15)
        }
        .padding()
        .navigationTransition(.zoom(sourceID: "Add", in: animation))
        .presentationDetents([.height(135)])
    }

    // MARK: - INIT

    init(context: ModelContext) {
        _viewModel = State(initialValue: ViewModel(context: context))
    }
}
