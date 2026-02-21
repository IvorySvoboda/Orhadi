//
//  DeletedStudyView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI
import SwiftData

struct DeletedStudiesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        List(selection: $vm.selectedStudies) {
            Section {} footer: {
                Text("The studies remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(vm.deletedStudies) { study in
                    DeletedStudyRow(study: study)
                        .tag(study)
                }
            }
        }
        .environment(vm)
        .navigationTitle("Deleted Studies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && .iOS26 ? .hidden : .visible, for: .tabBar)
        .toolbar { toolbarComponents }
        .onChange(of: vm.deletedStudies) { _, newStudies in
            if newStudies.isEmpty {
                dismiss()
            }
        }
    }

    // MARK: - Toolbar Components

    @ToolbarContentBuilder
    private var toolbarComponents: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            EditButton()
        }

        ToolbarItemGroup(placement: .bottomBar) {
            Button(vm.selectedStudies.isEmpty ? "Restore All" : "Restore") {
                vm.restoreStudies()
            }

            Spacer()

            Button(vm.selectedStudies.isEmpty ? "Delete All" : "Delete") {
                vm.showDeleteConfirmation.toggle()
            }
            .confirmationDialog(vm.deleteMessageText, isPresented: $vm.showDeleteConfirmation, titleVisibility: .visible) {
                Button(vm.deleteActionTitle, role: .destructive) {
                    vm.deleteStudies()
                }
            }
        }
    }
}
