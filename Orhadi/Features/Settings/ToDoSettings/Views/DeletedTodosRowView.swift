//
//  DeletedTodosRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI

struct DeletedTodosRowView: View {
    @State private var showDeleteConfirmation = false

    let todo: ToDo
    let onRestore: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(todo.title.nilIfEmpty() ?? String(localized: "Not provided"))
                    .font(.headline)
                    .lineLimit(1)

                CustomLabel("\(todo.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", systemImage: "trash.fill") {
                showDeleteConfirmation.toggle()
            }.tint(.red)

            Button("Restore", systemImage: "gobackward", role: .destructive) {
                onRestore()
            }.tint(.indigo)
        }
        .contextMenu {
            Button("Restore", systemImage: "gobackward") {
                onRestore()
            }

            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                showDeleteConfirmation.toggle()
            }
        }
        .alert("This to-do will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }
}
