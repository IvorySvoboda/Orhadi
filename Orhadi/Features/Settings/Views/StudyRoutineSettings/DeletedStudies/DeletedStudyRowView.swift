//
//  DeletedStudyRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
//

import SwiftUI

struct DeletedStudyRowView: View {
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false

    let study: SRStudy

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(study.name.nilIfEmpty() ?? "No Name")
                    .font(.headline)
                    .lineLimit(1)

                CustomLabel("\(study.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
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
                recoverStudy()
            } label: {
                Label("Restore", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }.tint(.indigo)
        }
        .alert("This study will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                withAnimation {
                    context.delete(study)
                }
            }
        }
    }

    private func recoverStudy() {
        withAnimation {
            study.isStudyDeleted = false
            study.deletedAt = nil
        }
    }
}
