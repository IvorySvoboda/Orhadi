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
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                deleteStudy()
            } label: {
                Image(systemName: "trash.fill")
            }

            Button {
                onAdd()
            } label: {
                Image(systemName: "rectangle.fill.on.rectangle.angled.fill")
            }.tint(.teal)

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
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
