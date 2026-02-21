//
//  DeletedStudyRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI

struct DeletedStudyRow: View {
    @Environment(DeletedStudiesView.ViewModel.self) private var vm
    @State private var showDeleteConfirmation = false
    let study: SRStudy

    var body: some View {
        VStack(alignment: .leading) {
            Text(study.name.nilIfEmpty() ?? "No Name")
                .titleStyle()
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
        .alert("This study will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                try? vm.hardDeleteStudy(study)
            }
        }
    }

    // MARK: - 'Deleted At' Label

    private var deletedAtLabel: some View {
        CustomLabel("\(study.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    // MARK: - Action Button

    private func restoreButton(destructive: Bool = false) -> some View {
        Button("Restore", systemImage: "gobackward", role: destructive ? .destructive : nil) {
            try? vm.restoreStudy(study)
        }
    }

    private func deleteButton(destructive: Bool = false) -> some View {
        Button("Delete", systemImage: "trash.fill", role: destructive ? .destructive : nil) {
            showDeleteConfirmation.toggle()
        }.tint(.red)
    }
}
