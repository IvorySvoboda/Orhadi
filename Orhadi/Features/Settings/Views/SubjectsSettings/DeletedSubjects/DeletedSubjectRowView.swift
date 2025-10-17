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
    @State private var showConflictAlert = false

    let subject: Subject

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
            
            Button(role: hasConflictWithOthersSubjects ? nil : .destructive) {
                if hasConflictWithOthersSubjects {
                    showConflictAlert.toggle()
                } else {
                    recoverSubject()
                }
            } label: {
                Label("Restore", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }.tint(.indigo)
        }
        .contextMenu {
            Button {
                if hasConflictWithOthersSubjects {
                    showConflictAlert.toggle()
                } else {
                    recoverSubject()
                }
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
        .alert("Conflict Detected!", isPresented: $showConflictAlert) {
            Button("Close") {}
        } message: {
            VStack(spacing: 10) {
                Text("The selected subject conflicts with an existing subject. Please adjust it before recovering.")
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
