//
//  ToDosDataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import SwiftUI

struct ToDosDataSettingsView: View {
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("All to-dos")
                    Spacer()
                    Text("\(vm.todos.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Completed")
                    Spacer()
                    Text("\(vm.completedTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Overdue")
                    Spacer()
                    Text("\(vm.overdueTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Pending")
                    Spacer()
                    Text("\(vm.pendingTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Archived")
                    Spacer()
                    Text("\(vm.archivedTodos)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Export To-Dos") {
                    try? vm.exportToDos()
                }
                .disabled(vm.todos.isEmpty)
                .fileExporter(
                    isPresented: $vm.showToDosFileExporter,
                    item: vm.todosExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "To-Dos")
                ) { result in
                    switch result {
                    case .success:
                        vm.todosExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        vm.todosExportItem = nil
                    }
                } onCancellation: {
                    vm.todosExportItem = nil
                }

                Button("Import To-Dos") {
                    vm.showToDosImportAlert.toggle()
                }
                .alert("Import To-Dos?", isPresented: $vm.showToDosImportAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Continue") {
                        vm.showToDosFileImporter.toggle()
                    }
                } message: {
                    Text("When importing, all existing to-dos will be deleted. Do you wish to continue?")
                }
                .fileImporter(
                    isPresented: $vm.showToDosFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        vm.importedURL = url
                        try? vm.importToDos()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }

            Section {
                Button("Delete All to-dos") {
                    vm.showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(vm.todos.isEmpty)
                .alert("Delete All to-dos?", isPresented: $vm.showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        try? vm.deleteAllToDos()
                    }
                }
            }
        }
        .navigationTitle("To-Dos")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error!", isPresented: $vm.showErrorMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}
