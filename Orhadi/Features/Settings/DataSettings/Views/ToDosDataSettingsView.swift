//
//  ToDosDataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import SwiftUI
import PopupView

struct ToDosDataSettingsView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ViewModel()

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("All to-dos")
                    Spacer()
                    Text("\(viewModel.todos.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Completed")
                    Spacer()
                    Text("\(viewModel.completedTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Overdue")
                    Spacer()
                    Text("\(viewModel.overdueTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Pending")
                    Spacer()
                    Text("\(viewModel.pendingTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Archived")
                    Spacer()
                    Text("\(viewModel.archivedTodos)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Export To-Dos") {
                    viewModel.exportToDos()
                }
                .disabled(viewModel.todos.isEmpty)
                .fileExporter(
                    isPresented: $viewModel.showToDosFileExporter,
                    item: viewModel.todosExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "To-Dos")
                ) { result in
                    switch result {
                    case .success:
                        viewModel.todosExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        viewModel.todosExportItem = nil
                    }
                } onCancellation: {
                    viewModel.todosExportItem = nil
                }

                Button("Import To-Dos") {
                    viewModel.showToDosImportAlert.toggle()
                }
                .alert("Import To-Dos?", isPresented: $viewModel.showToDosImportAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Continue") {
                        viewModel.showToDosFileImporter.toggle()
                    }
                } message: {
                    Text("When importing, all existing to-dos will be deleted. Do you wish to continue?")
                }
                .fileImporter(
                    isPresented: $viewModel.showToDosFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        viewModel.importedURL = url
                        viewModel.importToDos()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }

            Section {
                Button("Delete All to-dos") {
                    viewModel.showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(viewModel.todos.isEmpty)
                .alert("Delete All to-dos?", isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        viewModel.deleteAllToDo()
                    }
                }
            }
        }
        .navigationTitle("To-Dos")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.errorMessage, { _, _ in
            viewModel.handleErrorMessageChange()
        })
        .popup(isPresented: $viewModel.showErrorMessage) {
            Text(viewModel.errorMessage)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 60, leading: 5, bottom: 16, trailing: 5))
                .frame(maxWidth: .infinity)
                .background(Color.red)
        } customize: {
            $0
                .type(.toast)
                .position(.top)
                .animation(.smooth)
                .autohideIn(5)
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            viewModel.fetchToDos()
        }
        .onAppear {
            if viewModel.context == nil {
                viewModel.context = context
                viewModel.fetchToDos()
            }
        }
    }
}
