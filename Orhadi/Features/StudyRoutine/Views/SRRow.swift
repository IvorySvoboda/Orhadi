//
//  SRRow.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct SRRow: View, Equatable {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    var study: SRStudy
    var onStudy: () -> Void
    var onAdd: () -> Void
    var onEdit: () -> Void

    static func == (lhs: SRRow, rhs: SRRow) -> Bool {
        lhs.study.id == rhs.study.id
    }

    // MARK: - Views

    var body: some View {
        HStack {
            if study.hasStudiedThisWeek {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }

            Text(study.name.nilIfEmpty() ?? "Sem Nome")
                .lineLimit(1)
                .frame(maxWidth: 200, alignment: .leading)

            Spacer()

            Text(study.studyTime.formatToHour())
                .bold()
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            Button {
                onStudy()
            } label: {
                Label("Iniciar", systemImage: "play.circle.fill")
            }.tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteStudy()
            } label: {
                Label("Apagar", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }

            Button {
                onAdd()
            } label: {
                Label("Duplicar", systemImage: "rectangle.fill.on.rectangle.angled.fill")
                    .labelStyle(.iconOnly)
            }.tint(.teal)

            Button {
                onEdit()
            } label: {
                Label("Editar", systemImage: "pencil")
                    .labelStyle(.iconOnly)
            }.tint(.accentColor)
        }
    }

    // MARK: - Functions

    private func deleteStudy() {
        withAnimation {
            study.isStudyDeleted = true
            study.deletedAt = .now
        }
    }
}
