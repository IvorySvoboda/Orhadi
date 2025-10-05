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
    @State private var scrollOffsetY: Int = 151

    // MARK: - Computed Properties

    var visibleToDos: [ToDo] {
        selectedSection == .pending ? pendingToDos : completedToDos
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                if #available(iOS 26, *) {
                    sectionPickerBar
                        .opacity(scrollOffsetY < 56 ? 0 : 1)
                } else {
                    sectionPickerBar
                }

                ForEach(visibleToDos) { todo in
                    ToDoRowView(
                        todo: todo,
                        onEdit: { todoToEdit = todo }
                    )
                }
            }
            .orhadiPlainListStyle()
            .navigationTitle("To-Do")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        if #available(iOS 26, *) {
                            Text("To-Do")
                                .font(.headline)
                                .opacity(scrollOffsetY < 108 ? 1 : 0)
                                .blur(radius: scrollOffsetY < 108 ? 0 : 3)
                                .offset(y: scrollOffsetY <= 56 ? -8 : scrollOffsetY < 108 ? 0 : 14)

                            Text(selectedSection.string.uppercased())
                                .foregroundStyle(.tint)
                                .font(.caption)
                                .opacity(scrollOffsetY <= 56 ? 1 : 0)
                                .blur(radius: scrollOffsetY <= 56 ? 0 : 3)
                                .offset(y: scrollOffsetY <= 56 ? 8 : 14)
                        } else {
                            Text("To-Do")
                                .font(.headline)
                                .opacity(scrollOffsetY < 115 ? 1 : 0)
                                .offset(y: scrollOffsetY <= 60 ? -8 : 0)

                            Text(selectedSection.string.uppercased())
                                .foregroundStyle(.tint)
                                .font(.caption)
                                .opacity(scrollOffsetY <= 60 ? 1 : 0)
                                .offset(y: scrollOffsetY <= 60 ? 8 : 14)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        todoToAdd = ToDo()
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

    private var sectionPickerBar: some View {
        ToDosSectionPickerBar(selectedSection: $selectedSection)
            .background(
                GeometryReader { geo in
                    let minY = geo.frame(in: .global).minY
                    Color.clear
                        .onChange(of: minY) { _, _ in
                            if #available(iOS 26, *) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation(.smooth(duration: 0.5)) {
                                        scrollOffsetY = Int(minY)
                                    }
                                }
                            } else {
                                withAnimation(.smooth(duration: 0.25)) {
                                    scrollOffsetY = Int(minY)
                                }
                            }
                        }
                }
            )
    }

    private var overlay: some View {
        Group {
            if visibleToDos.isEmpty, scrollOffsetY < 300 {
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
