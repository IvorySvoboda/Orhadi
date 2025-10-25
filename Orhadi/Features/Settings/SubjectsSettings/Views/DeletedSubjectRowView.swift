//
//  DeletedSubjectRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
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
            context: context
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
            Button("Delete", systemImage: "trash.fill") {
                showDeleteConfirmation.toggle()
            }.tint(.red)

            Button("Restore", systemImage: "gobackward", role: hasConflictWithOthersSubjects ? nil : .destructive) {
                recoverSubject()
            }.tint(.indigo)
        }
        .contextMenu {
            Button("Restore", systemImage: "gobackward") {
                recoverSubject()
            }

            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                showDeleteConfirmation.toggle()
            }
        }
        .alert("This subject will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                try? subject.hardDelete(in: context)
            }
        }
    }

    private func recoverSubject() {
        if hasConflictWithOthersSubjects {
            showConflictAlert()
        } else {
            try? subject.restore(in: context)
        }
    }
}
