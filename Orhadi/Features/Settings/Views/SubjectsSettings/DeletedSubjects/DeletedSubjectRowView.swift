//
//  DeletedSubjectRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
//

import SwiftUI

struct DeletedSubjectRowView: View {
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false

    let subject: Subject

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if subject.isRecess {
                    Text("Interval")
                        .font(.headline)
                        .lineLimit(1)
                } else {
                    Text(subject.name.nilIfEmpty() ?? "No Name")
                        .font(.headline)
                        .lineLimit(1)
                }

                CustomLabel("\(subject.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
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
                Label("Delete", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }.tint(.red)

            Button(role: .destructive) {
                recoverSubject()
            } label: {
                Label("Restore", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }.tint(.indigo)
        }
        .contextMenu {
            Button {
                recoverSubject()
            } label: {
                Label("Restore", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }

            Button(role: .destructive) {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Delete", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }
        }
        .alert("This subject will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                withAnimation {
                    context.delete(subject)
                }
            }
        }
    }

    private func recoverSubject() {
        withAnimation {
            subject.isSubjectDeleted = false
            subject.deletedAt = nil
        }
    }
}
