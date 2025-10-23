//
//  ToDosView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 26/03/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct ToDosView: View {
    @Query(filter: #Predicate<ToDo> {
        !$0.isArchived && !$0.isToDoDeleted && !$0.isCompleted
    }, sort: [
        .init(\.dueDate, order: .forward),
        .init(\.title, order: .forward)
    ]) private var pendingToDos: [ToDo]

    @Query(filter: #Predicate<ToDo> {
        !$0.isArchived && !$0.isToDoDeleted && $0.isCompleted
    }, sort: \ToDo.completedAt, order: .reverse) private var completedToDos: [ToDo]

    @State private var viewModel = ViewModel()

    var visibleToDos: [ToDo] {
        viewModel.selectedSection == .pending ? pendingToDos : completedToDos
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                ToDosSectionPickerBar(selectedSection: $viewModel.selectedSection)
                    .opacity(viewModel.showSelectedSection ? 0 : 1)

                ForEach(visibleToDos) { todo in
                    ToDoRowView(
                        todo: todo,
                        onEdit: { viewModel.todoToEdit = todo }
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("To-Do")
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y
            }, action: { _, scrollOffset in
                viewModel.handleScrollGeoChange(scrollOffset)
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("To-Do")
                            .font(.headline)
                            .frame(height: 30)
                            .opacity(viewModel.showTitle ? 1 : 0)
                            .blur(radius: viewModel.showTitle ? 0 : 3)
                            .offset(y: viewModel.showSelectedSection ? -8 : viewModel.showTitle ? 0 : 14)

                        Text(viewModel.selectedSection.string)
                            .textCase(.uppercase)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .frame(height: 30)
                            .opacity(viewModel.showSelectedSection ? 1 : 0)
                            .blur(radius: viewModel.showSelectedSection ? 0 : 3)
                            .offset(y: viewModel.showSelectedSection ? 8 : 14)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        viewModel.todoToAdd = ToDo()
                    }.tint(.accentColor)
                }
            }
            .overlay {
                if visibleToDos.isEmpty, !viewModel.hideOverlay {
                    ContentUnavailableView {
                        Label(
                            viewModel.selectedSection == .pending ? "No Pending To-Dos" : "No Completed To-Dos",
                            systemImage: "list.bullet.clipboard")
                    } description: {
                        Text(
                            viewModel.selectedSection == .pending
                            ? "Add new To-Dos to start getting organized."
                            : "Complete To-Dos to see them here."
                        )
                    } actions: {
                        Button("Add To-Do") {
                            viewModel.todoToAdd = ToDo()
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(Color.orhadiBG)
                    }
                }
            }
            .sheet(item: $viewModel.todoToAdd) { todo in
                ToDoSheetView(todo: todo, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $viewModel.todoToEdit) { todo in
                ToDoSheetView(todo: todo, isNew: false)
                    .interactiveDismissDisabled()
            }
            .onChange(of: completedToDos) { _, _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: pendingToDos) { _, _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

#Preview("ToDoView") {
    ToDosView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
