//
//  DeletedSubjectRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI

struct DeletedSubjectRow: View {
    @Environment(DeletedSubjectsView.ViewModel.self) private var vm
    @State private var showDeleteConfirmation = false
    let subject: Subject

    var body: some View {
        VStack(alignment: .leading) {
            deletedSubjectName
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
        .alert("This subject will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                try? vm.hardDeleteSubject(subject)
            }
        }
    }

    // MARK: - Deleted Subject Name

    private var deletedSubjectName: some View {
        if subject.isRecess {
            Text("Interval")
                .titleStyle()
        } else {
            Text(subject.name.nilIfEmpty() ?? "No Name")
                .titleStyle()
        }
    }

    // MARK: - 'Deleted At' Label

    private var deletedAtLabel: some View {
        CustomLabel("\(subject.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    // MARK: - Action Button

    private func restoreButton(destructive: Bool = false) -> some View {
        Button("Restore", systemImage: "gobackward", role: destructive ? .destructive : nil) {
            try? vm.restoreSubject(subject)
        }
    }

    private func deleteButton(destructive: Bool = false) -> some View {
        Button("Delete", systemImage: "trash.fill", role: destructive ? .destructive : nil) {
            showDeleteConfirmation.toggle()
        }.tint(.red)
    }
}
