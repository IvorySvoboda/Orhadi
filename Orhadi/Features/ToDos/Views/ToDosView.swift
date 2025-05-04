//
//  ToDosView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

struct ToDosView: View {
    @Query(filter: #Predicate<ToDo> {
        !$0.isArchived && !$0.isToDoDeleted && !$0.isCompleted
    }, sort: [
        .init(\.dueDate, order: .forward),
        .init(\.title, order: .forward),
    ]) private var pendingToDos: [ToDo]

    @Query(filter: #Predicate<ToDo> {
        !$0.isArchived && !$0.isToDoDeleted && $0.isCompleted
    }, sort: \ToDo.completedAt, order: .reverse) private var completedToDos: [ToDo]

    // MARK: - Properties

    @State private var todoToAdd: ToDo? = nil
    @State private var todoToEdit: ToDo? = nil
    @State private var selectedSection: ToDoSection = .pending
    @State private var offsetScrollY: Int = 151

    // MARK: - Computed Properties

    var visibleToDos: [ToDo] {
        selectedSection == .pending ? pendingToDos : completedToDos
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                sectionPickerBar

                ForEach(visibleToDos) { todo in
                    ToDoRowView(
                        todo: todo,
                        onEdit: { todoToEdit = todo }
                    )
                }
            }
            .id(selectedSection)
            .orhadiPlainListStyle()
            .navigationTitle("Tarefas")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Tarefas")
                            .font(.headline)
                            .opacity(offsetScrollY < 115 ? 1 : 0)
                            .offset(y: offsetScrollY <= 60 ? -8 : 0)

                        Text(selectedSection.string.uppercased())
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .opacity(offsetScrollY <= 60 ? 1 : 0)
                            .offset(y: offsetScrollY <= 60 ? 8 : 14)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        todoToAdd = ToDo()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
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
        }
    }

    private var sectionPickerBar: some View {
        ToDosSectionPickerBar(selectedSection: $selectedSection)
            .background(
                GeometryReader { geo in
                    let minY = geo.frame(in: .global).minY
                    Color.clear
                        .onChange(of: minY) { _, _ in
                            withAnimation(.smooth(duration: 0.25)) {
                                offsetScrollY = Int(minY)
                            }
                        }
                }
            )
    }

    private var overlay: some View {
        Group {
            if visibleToDos.isEmpty, offsetScrollY < 300 {
                ContentUnavailableView {
                    Label(
                        selectedSection == .pending ? "Nenhuma Tarefa Pendente" : "Nenhuma Tarefa Concluída",
                        systemImage: "list.bullet.clipboard")
                } description: {
                    Text(
                        selectedSection == .pending
                        ? "Adicione novas tarefas para começar a se organizar."
                        : "Conclua tarefas para vê-las aqui."
                    )
                } actions: {
                    Button("Adicionar Tarefa") {
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
