//
//  DeletedStudyRowView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/05/25.
//

import SwiftUI

struct DeletedStudyRowView: View {
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false

    let study: SRStudy

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(study.name.nilIfEmpty() ?? "Sem Nome")
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
                recoverStudy()
            } label: {
                Label("Recuperar", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }

            Button(role: .destructive) {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Apagar", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }
        }
        .confirmationDialog("Este estudo será apagado. Esta ação não poderá ser desfeita.",
                            isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Apagar Estudo", role: .destructive) {
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
