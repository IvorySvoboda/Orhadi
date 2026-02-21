//
//  SRSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 21/04/25.
//

import SwiftUI
import SwiftData

struct SRSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ViewModel

    // MARK: - INIT

    init(study: SRStudy, isNew: Bool) {
        _vm = State(initialValue: ViewModel(study: study, isNew: isNew, dataManager: .shared))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                studyInfoSection
                scheduleSection
            }
            .navigationTitle(vm.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarComponents }
        }
    }

    // MARK: - Form Components

    private var studyInfoSection: some View {
        Section {
            TextField("Name (ex: English)", text: $vm.draftStudy.name)
                .autocorrectionDisabled()

            DatePicker(
                "Study Duration",
                selection: $vm.draftStudy.studyTime,
                displayedComponents: [.hourAndMinute]
            )
        }
    }

    private var scheduleSection: some View {
        Section {
            WeekdayPicker(selection: $vm.draftStudy.studyDay)
        } header: {
            Text("Study Schedule")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarComponents: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", role: .cancel) {
                dismiss()
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save", systemImage: "checkmark") {
                try? vm.trySave {
                    dismiss()
                }
            }.disabled(vm.draftStudy.name.isEmpty)
        }
    }
}
