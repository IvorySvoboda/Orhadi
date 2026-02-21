//
//  DeletedTodosRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI

struct DeletedTodosRow: View {
    @Environment(DeletedTodosView.ViewModel.self) private var vm
    @State private var showDeleteConfirmation = false

    let todo: ToDo

    var body: some View {
        VStack(alignment: .leading) {
            todoTitle
            deletedAtLabel
        }
        .swipeActions(edge: .leading) {
            restoreButton(destructive: true).tint(.indigo)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteButton().tint(.red)
        }
        .contextMenu {
            restoreButton()
            deleteButton(destructive: true)
        }
        .alert("This to-do will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                try? vm.hardDeleteToDo(todo)
            }
        }
    }

    // MARK: - To-Do Title

    private var todoTitle: some View {
        Text(todo.title)
            .titleStyle()
    }

    // MARK: - 'Deleted At' Label

    private var deletedAtLabel: some View {
        CustomLabel("\(todo.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    // MARK: - Action Button

    private func restoreButton(destructive: Bool = false) -> some View {
        Button("Restore", systemImage: "gobackward", role: destructive ? .destructive : nil) {
            try? vm.restoreToDo(todo)
        }
    }

    private func deleteButton(destructive: Bool = false) -> some View {
        Button("Delete", systemImage: "trash.fill", role: destructive ? .destructive : nil) {
            showDeleteConfirmation.toggle()
        }.tint(.red)
    }
}
