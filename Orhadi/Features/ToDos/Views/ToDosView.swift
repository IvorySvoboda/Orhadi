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

    // MARK: - Properties

    @State private var todoToAdd: ToDo?
    @State private var todoToEdit: ToDo?
    @State private var selectedSection: ToDoSection = .pending
    @State private var showTitle: Bool = false
    @State private var showSelectedSection: Bool = false
    @State private var hideOverlay: Bool = false

    // MARK: - Computed Properties

    var visibleToDos: [ToDo] {
        selectedSection == .pending ? pendingToDos : completedToDos
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                ToDosSectionPickerBar(selectedSection: $selectedSection)
                    .opacity(showSelectedSection ? 0 : 1)

                ForEach(visibleToDos) { todo in
                    ToDoRow(
                        todo: todo,
                        onEdit: { todoToEdit = todo }
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("To-Do")
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y
            }, action: { _, scrollOffset in
                debugPrint(scrollOffset)

                let shouldShowTitle = scrollOffset >= -101
                if shouldShowTitle != showTitle {
                    withAnimation(.smooth(duration: 0.5)) {
                        showTitle = shouldShowTitle
                    }
                }

                let shouldShowWeekday = scrollOffset >= -56
                if shouldShowWeekday != showSelectedSection {
                    withAnimation(.smooth(duration: 0.5)) {
                        showSelectedSection = shouldShowWeekday
                    }
                }

                let shouldHideOverlay = scrollOffset < -300
                if shouldHideOverlay != hideOverlay {
                    withAnimation(.smooth(duration: 0.5)) {
                        hideOverlay = shouldHideOverlay
                    }
                }
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("To-Do")
                            .font(.headline)
                            .frame(height: 30)
                            .opacity(showTitle ? 1 : 0)
                            .blur(radius: showTitle ? 0 : 3)
                            .offset(y: showSelectedSection ? -8 : showTitle ? 0 : 14)

                        Text(selectedSection.string)
                            .textCase(.uppercase)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .frame(height: 30)
                            .opacity(showSelectedSection ? 1 : 0)
                            .blur(radius: showSelectedSection ? 0 : 3)
                            .offset(y: showSelectedSection ? 8 : 14)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        todoToAdd = ToDo()
                    }.tint(.accentColor)
                }
            }
            .overlay { overlay }
            .sheet(item: $todoToAdd) { todo in
                ToDoSheetView(todo: todo, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $todoToEdit) { todo in
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

    private var overlay: some View {
        Group {
            if visibleToDos.isEmpty, !hideOverlay {
                ContentUnavailableView {
                    Label(
                        selectedSection == .pending ? "No Pending To-Dos" : "No Completed To-Dos",
                        systemImage: "list.bullet.clipboard")
                } description: {
                    Text(
                        selectedSection == .pending
                        ? "Add new To-Dos to start getting organized."
                        : "Complete To-Dos to see them here."
                    )
                } actions: {
                    Button("Add To-Do") {
                        todoToAdd = ToDo()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(Color.orhadiBG)
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
