//
//  ToDosView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/03/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct ToDosView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ViewModel()

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                ToDosSectionPickerBar(selectedSection: $viewModel.selectedSection)
                    .opacity(viewModel.showSelectedSection ? 0 : 1)

                ForEach(viewModel.visibleToDos) { todo in
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
                if viewModel.visibleToDos.isEmpty, !viewModel.hideOverlay {
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
                ToDoSheetView(todo: todo, isNew: true, context: context)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $viewModel.todoToEdit) { todo in
                ToDoSheetView(todo: todo, isNew: false, context: context)
                    .interactiveDismissDisabled()
            }
            .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
                viewModel.fetchToDos()
            }
            .onAppear {
                if viewModel.context == nil {
                    viewModel.context = context
                    viewModel.fetchToDos()
                }
            }
        }
    }
}

#Preview("ToDoView") {
    ToDosView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
