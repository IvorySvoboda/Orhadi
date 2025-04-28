//
//  SRDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI

struct SRDataSettingsView: View {

    @State private var viewModel = SRDataSettingsViewModel()

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total de Estudos")
                    Spacer()
                    Text("\(viewModel.studies?.count ?? 0)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Exportar Rotina de Estudos") {
                    viewModel.exportSR()
                }
                .disabled(viewModel.studies?.isEmpty ?? true)
                .fileExporter(
                    isPresented: $viewModel.showSRFileExporter,
                    item: viewModel.srExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Rotina de Estudos")
                ) { result in
                    switch result {
                    case .success(_):
                        print("Sucesso!")
                        viewModel.srExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        viewModel.srExportItem = nil
                    }
                } onCancellation: {
                    viewModel.srExportItem = nil
                }

                Button("Importar Rotina de Estudos") {
                    viewModel.showSRImportAlert.toggle()
                }
                .alert("Importar Rotina de Estudos?", isPresented: $viewModel.showSRImportAlert) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Continuar") {
                        viewModel.showSRFileImporter.toggle()
                    }
                } message: {
                    Text("Ao importar uma nova rotina de estudo todas os itens já existentes na rotina atual serão removidas. Deseja continuar?")
                }
                .fileImporter(
                    isPresented: $viewModel.showSRFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        viewModel.importedURL = url
                        viewModel.importSR()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Apagar todos os estudos") {
                    viewModel.showDeleteConfirmation.toggle()
                }.tint(.red)
                    .alert("Apagar todos os estudos?", isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        viewModel.deleteAllStudies()
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Rotina de Estudos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
