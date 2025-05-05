//
//  DeletedTodosRowView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/05/25.
//

import SwiftUI

struct DeletedTodosRowView: View {
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false

    let todo: ToDo

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(todo.title.nilIfEmpty() ?? String(localized: "Não Informado"))
                    .font(.headline)
                    .lineLimit(1)

                CustomLabel("\(todo.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Apagar", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }.tint(.red)

            Button(role: .destructive) {
                recoverTodo()
            } label: {
                Label("Recuperar", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }.tint(.indigo)
        }
        .contextMenu {
            Button {
                recoverTodo()
            } label: {
                Label("Recuperar", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }

            Button(role: .destructive) {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Apagar", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }
        }
        .confirmationDialog("Esta tarefa será apagada. Esta ação não poderá ser desfeita.",
                            isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Apagar Tarefa", role: .destructive) {
                withAnimation {
                    context.delete(todo)
                }
            }
        }
    }

    private func recoverTodo() {
        withAnimation {
            todo.isToDoDeleted = false
            todo.deletedAt = nil
            if !todo.isCompleted, todo.dueDate > .now, !todo.isArchived {
                todo.scheduleNotification()
            }
        }
    }
}
