//
//  DeletedSubjectsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct DeletedSubjectsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        List(selection: $vm.selectedSubjects) {
            Section {} footer: {
                Text("The subjects remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(vm.deletedSubjects) { subject in
                    DeletedSubjectRow(subject: subject)
                        .tag(subject)
                }
            }
        }
        .environment(vm)
        .navigationTitle("Deleted Subjects")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && .iOS26 ? .hidden : .visible, for: .tabBar)
        .toolbar { toolbarComponents }
        .alert("Conflict Detected!", isPresented: $vm.showConflictAlert) {
            Button("Close") {}
        } message: {
            Text("One or more subjects conflict with existing ones. Please adjust them before recovering.")
        }
        .onChange(of: vm.deletedSubjects) { _, _ in
            if vm.deletedSubjects.isEmpty {
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
            Button(vm.selectedSubjects.isEmpty ? "Restore All" : "Restore") {
                vm.restoreSubjects()
            }

            Spacer()

            Button(vm.selectedSubjects.isEmpty ? "Delete All" : "Delete") {
                vm.showDeleteConfirmation.toggle()
            }
            .confirmationDialog(vm.deleteMessageText, isPresented: $vm.showDeleteConfirmation, titleVisibility: .visible) {
                Button(vm.deleteActionTitle, role: .destructive) {
                    vm.deleteSubjects()
                }
            }
        }
    }
}
