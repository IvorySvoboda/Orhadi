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
    let showConflictAlert: () -> Void

    var hasConflictWithOthersSubjects: Bool {
        return SubjectConflictVerifier.hasConflictWithOtherSubjects(
            id: subject.id,
            start: subject.startTime,
            end: subject.endTime,
            schedule: subject.schedule,
            context:  context
        )
    }

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
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Delete", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }

            Button(role: hasConflictWithOthersSubjects ? nil : .destructive) {
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
                withAnimation { context.delete(subject) }
            }
        }
    }

    private func recoverSubject() {
        if hasConflictWithOthersSubjects {
            showConflictAlert()
        } else {
            subject.restore()
        }
    }
}
