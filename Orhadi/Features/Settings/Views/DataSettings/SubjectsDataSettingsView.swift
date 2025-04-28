//
//  SubjectsDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI

struct SubjectsDataSettingsView: View {

    @State private var viewModel = SubjectsDataSettingsViewModel()

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total de Itens")
                    Spacer()
                    Text("\((viewModel.subjects?.count ?? 0))")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Matérias")
                    Spacer()
                    Text("\(viewModel.allSubjects)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Intervalos")
                    Spacer()
                    Text("\(viewModel.allRecess)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Exportar Matérias") {
                    viewModel.exportSubjects()
                }
                .disabled((viewModel.subjects?.isEmpty ?? true))
                .fileExporter(
                    isPresented: $viewModel.showSubjectsFileExporter,
                    item: viewModel.subjectsExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Matérias")
                ) { result in
                    switch result {
                    case .success(_):
                        viewModel.subjectsExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        viewModel.subjectsExportItem = nil
                    }
                } onCancellation: {
                    viewModel.subjectsExportItem = nil
                }

                Button("Importar Matérias") {
                    viewModel.showSubjectsImportAlert.toggle()
                }
                .alert("Importar Matérias?", isPresented: $viewModel.showSubjectsImportAlert) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Continuar") {
                        viewModel.showSubjectsFileImporter.toggle()
                    }
                } message: {
                    Text("Ao importar, todas as matérias todas as matérias existentes serão removidas. Deseja continuar?")
                }
                .fileImporter(
                    isPresented: $viewModel.showSubjectsFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        viewModel.importedURL = url
                        viewModel.importSubject()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Apagar todas as matérias") {
                    viewModel.showDeleteConfirmation.toggle()
                }.tint(.red)
                    .alert("Apagar todas as matérias?", isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        viewModel.deleteAllSubjects()
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
    }
}
