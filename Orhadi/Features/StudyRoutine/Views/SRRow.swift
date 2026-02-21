//
//  SRRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/04/25.
//

import SwiftUI

struct SRRow: View {
    @Environment(SRView.ViewModel.self) private var vm
    @Environment(Settings.self) private var settings
    let study: SRStudy

    // MARK: - Views

    var body: some View {
        HStack {
            if study.hasStudiedThisWeek {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }

            VStack(alignment: .leading) {
                Text(study.name)
                    .titleStyle()
                CustomLabel(
                    LocalizedStringKey(study.lastStudied?.friendlyDateString ?? "Never Studied"),
                    systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(study.studyTimeInSeconds.durationString())
                .bold()
        }
        .swipeActions(edge: .leading) {
            studyButton.tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            deleteButton
            duplicateButton.tint(.teal)
            editButton.tint(.accentColor)
        }
        .contextMenu {
            studyButton
            editButton
            duplicateButton
            deleteButton
        }
    }

    // MARK: - Action Buttons

    private var studyButton: some View {
        Button("Start Study", systemImage: "play.circle.fill") {
            vm.studiesToStudy = [study]
            vm.navigateToStudyingView.toggle()
        }
    }

    private var editButton: some View {
        Button("Edit", systemImage: "pencil") {
            vm.studyToEdit = study
        }
    }

    private var duplicateButton: some View {
        Button("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill") {
            vm.studyToAdd = study
        }
    }

    private var deleteButton: some View {
        Button("Delete", systemImage: "trash.fill", role: .destructive) {
            try? vm.softDeleteStudy(study)
        }
    }

}
