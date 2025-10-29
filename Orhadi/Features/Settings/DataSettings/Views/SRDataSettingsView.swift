//
//  SRDataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import SwiftUI

struct SRDataSettingsView: View {
    @State private var viewModel = ViewModel(dataManager: .shared)

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total Studies")
                    Spacer()
                    Text("\(viewModel.studies.count)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Export Study Routine") {
                    try? viewModel.exportSR()
                }
                .disabled(viewModel.studies.isEmpty)
                .fileExporter(
                    isPresented: $viewModel.showSRFileExporter,
                    item: viewModel.srExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Study Routine")
                ) { result in
                    switch result {
                    case .success:
                        print("Success!")
                        viewModel.srExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        viewModel.srExportItem = nil
                    }
                } onCancellation: {
                    viewModel.srExportItem = nil
                }

                Button("Import Study Routine") {
                    viewModel.showSRImportAlert.toggle()
                }
                .alert("Import Study Routine?", isPresented: $viewModel.showSRImportAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Continue") {
                        viewModel.showSRFileImporter.toggle()
                    }
                } message: {
                    Text("When importing a new study routine, all existing studies in the current routine will be deleted. Do you want to continue?")
                }
                .fileImporter(
                    isPresented: $viewModel.showSRFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        viewModel.importedURL = url
                        try? viewModel.importSR()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }

            Section {
                Button("Delete all studies") {
                    viewModel.showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(viewModel.studies.isEmpty)
                .alert("Delete all studies?", isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        try? viewModel.deleteAllStudies()
                    }
                }
            }
        }
        .navigationTitle("Study Routine")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error!", isPresented: $viewModel.showErrorMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
