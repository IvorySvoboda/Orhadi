//
//  SRDataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import SwiftUI

struct SRDataSettingsView: View {
    @State private var vm = ViewModel(dataManager: .shared)

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total Studies")
                    Spacer()
                    Text("\(vm.studies.count)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Export Study Routine") {
                    try? vm.exportSR()
                }
                .disabled(vm.studies.isEmpty)
                .fileExporter(
                    isPresented: $vm.showSRFileExporter,
                    item: vm.srExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Study Routine")
                ) { result in
                    switch result {
                    case .success:
                        print("Success!")
                        vm.srExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        vm.srExportItem = nil
                    }
                } onCancellation: {
                    vm.srExportItem = nil
                }

                Button("Import Study Routine") {
                    vm.showSRImportAlert.toggle()
                }
                .alert("Import Study Routine?", isPresented: $vm.showSRImportAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Continue") {
                        vm.showSRFileImporter.toggle()
                    }
                } message: {
                    Text("When importing a new study routine, all existing studies in the current routine will be deleted. Do you want to continue?")
                }
                .fileImporter(
                    isPresented: $vm.showSRFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        vm.importedURL = url
                        try? vm.importSR()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }

            Section {
                Button("Delete all studies") {
                    vm.showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(vm.studies.isEmpty)
                .alert("Delete all studies?", isPresented: $vm.showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        try? vm.deleteAllStudies()
                    }
                }
            }
        }
        .navigationTitle("Study Routine")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error!", isPresented: $vm.showErrorMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}
