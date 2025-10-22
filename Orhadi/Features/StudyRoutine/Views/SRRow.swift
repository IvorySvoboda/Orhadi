//
//  SRRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 26/04/25.
//

import SwiftUI

struct SRRow: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    var study: SRStudy
    var onStudy: () -> Void
    var onAdd: () -> Void
    var onEdit: () -> Void

    // MARK: - Views

    var body: some View {
        HStack {
            if study.hasStudiedThisWeek {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }

            Text(study.name.nilIfEmpty() ?? "No Name")
                .lineLimit(1)
                .frame(maxWidth: 200, alignment: .leading)

            Spacer()

            Text(study.studyTimeInSeconds.durationString())
                .bold()
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            Button("Study", systemImage: "play.circle.fill") {
                onStudy()
            }.tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                study.delete()
            }

            Button("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill") {
                onAdd()
            }.tint(.teal)

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }.tint(.accentColor)
        }
        .contextMenu {
            Button("Study", systemImage: "play.circle.fill") {
                onStudy()
            }

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }

            Button("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill") {
                onAdd()
            }

            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                study.delete()
            }
        }
    }
}
