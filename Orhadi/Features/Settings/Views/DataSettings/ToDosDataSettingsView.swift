//
//  ToDosDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI

struct ToDosDataSettingsView: View {
    @Environment(Settings.self) private var settings
    @Query(animation: .smooth) private var todos: [ToDo]

    @State private var viewModel = ToDosDataSettingsViewModel()

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total de tarefas")
                    Spacer()
                    Text("\(viewModel.todos?.count ?? 0)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Concluídas")
                    Spacer()
                    Text("\(viewModel.completedTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Atrasadas")
                    Spacer()
                    Text("\(viewModel.overdueTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("A Fazer")
                    Spacer()
                    Text("\(viewModel.pendingTodos)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Exportar Tarefas") {
                    viewModel.exportToDos()
                }
                .disabled(todos.isEmpty)
                .fileExporter(
                    isPresented: $viewModel.showToDosFileExporter,
                    item: viewModel.todosExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Tarefas")
                ) { result in
                    switch result {
                    case .success(_):
                        viewModel.todosExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        viewModel.todosExportItem = nil
                    }
                } onCancellation: {
                    viewModel.todosExportItem = nil
                }

                Button("Importar Tarefas") {
                    viewModel.showToDosImportAlert.toggle()
                }
                .alert("Importar Tarefas?", isPresented: $viewModel.showToDosImportAlert) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Continuar") {
                        viewModel.showToDosFileImporter.toggle()
                    }
                } message: {
                    Text("Ao importar, todas as tarefas todas as tarefas existentes serão removidas. Deseja continuar?")
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
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Apagar todas as tarefas") {
                    viewModel.showDeleteConfirmation.toggle()
                }.tint(.red)
                    .alert("Apagar todas as tarefas?", isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        viewModel.deleteAllToDo()
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Tarefas")
        .navigationBarTitleDisplayMode(.inline)
    }
}
