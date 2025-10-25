//
//  DeletedStudyRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
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
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", systemImage: "trash.fill") {
                showDeleteConfirmation.toggle()
            }.tint(.red)

            Button("Restore", systemImage: "gobackward", role: .destructive) {
                try? study.restore(in: context)
            }.tint(.indigo)
        }
        .contextMenu {
            Button("Restore", systemImage: "gobackward") {
                try? study.restore(in: context)
            }

            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                showDeleteConfirmation.toggle()
            }
        }
        .alert("This study will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                try? study.hardDelete(in: context)
            }
        }
    }
}
