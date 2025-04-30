//
//  TasksView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

enum ToDoSection: CaseIterable {
    case pending, completed

    var string: String {
        switch self {
        case .pending: return String(localized: "A Fazer")
        case .completed: return String(localized: "Concluídos")
        }
    }
}

struct ToDosView: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    // MARK: - Queries

    @Query(filter: #Predicate<ToDo> {
        !$0.isArchived && !$0.isCompleted && !$0.isDeleted
    }, sort: [
        .init(\.dueDate, order: .forward),
        .init(\.title, order: .forward),
    ], animation: .smooth) private var pendingToDos: [ToDo]

    @Query(filter: #Predicate<ToDo> {
        !$0.isArchived && $0.isCompleted && !$0.isDeleted
    }, sort: \ToDo.completedAt, order: .reverse, animation: .smooth) private var completedToDos: [ToDo]

    // MARK: - Properties

    @State private var timer: Timer? = nil
    @State private var todoToAdd: ToDo? = nil
    @State private var todoToEdit: ToDo? = nil
    @State private var selectedSection: ToDoSection = .pending
    @State private var offsetScrollY: Int = 151

    // MARK: - Views

    var body: some View {
            NavigationStack {
                List {
                    todoPickerBar

                    ForEach(selectedSection == .pending ? pendingToDos.sorted(by: { $0.priority > $1.priority }) : completedToDos) { todo in
                        ToDoRow(todo: todo, todoToEdit: $todoToEdit)
                            .listRowBackground(Color.orhadiBG)
                    }
                }
                .orhadiPlainListStyle()
                .navigationTitle("Tarefas")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        principalToolbar
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

    private var principalToolbar: some View {
        ZStack {
            Text("Tarefas")
                .font(.headline)
                .opacity(offsetScrollY < 115 ? 1 : 0)
                .offset(y: offsetScrollY <= 70 ? -8 : 0)

            Text(selectedSection.string.uppercased())
                .foregroundStyle(.tint)
                .font(.caption)
                .opacity(offsetScrollY <= 70 ? 1 : 0)
                .offset(y: offsetScrollY <= 70 ? 8 : 14)
        }
    }

    private var todoPickerBar: some View {
        ToDosSectionPickerBar(selectedSection: $selectedSection)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _, newY in
                            withAnimation {
                                offsetScrollY = Int(newY)
                            }
                        }
                }
            )
    }


    private var overlay: some View {
        Group {
            let todos = selectedSection == .pending ? pendingToDos : completedToDos
            if todos.isEmpty, offsetScrollY < 300 {
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

struct ToDosSectionPickerBar: View {

    @Binding var selectedSection: ToDoSection

    @State private var isPressed: ToDoSection?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(ToDoSection.allCases, id: \.string) { section in
                ZStack {
                    Text("\(section.string)")
                        .font(.callout)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(selectedSection == section ? Color.orhadiBG : .primary)
                }
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(selectedSection == section ? Color.accentColor : Color.orhadiSecondaryBG)
                )
                .scaleEffect(isPressed == section ? 1.05 : 1)
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.75)) {
                        selectedSection = section
                    }
                }
                .sensoryFeedback(.impact(intensity: 0.8), trigger: selectedSection)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.6)) {
                                isPressed = section
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                                isPressed = nil
                            }
                        }
                )
                .id(section)
            }
        }
        .padding(.horizontal)
        .frame(height: 40)
        .listRowInsets(
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
