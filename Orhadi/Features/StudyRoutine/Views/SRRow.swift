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
            Button {
                onStudy()
            } label: {
                Label("Study", systemImage: "play.circle.fill")
            }.tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                study.delete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }

            Button {
                onAdd()
            } label: {
                Label("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill")
                    .labelStyle(.iconOnly)
            }.tint(.teal)

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
                    .labelStyle(.iconOnly)
            }.tint(.accentColor)
        }
        .contextMenu {
            Button {
                onStudy()
            } label: {
                Label("Study", systemImage: "play.circle.fill")
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                onAdd()
            } label: {
                Label("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill")
            }

            Button(role: .destructive) {
                study.delete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
}
