//
//  SubjectsDataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import SwiftUI

struct SubjectsDataSettingsView: View {
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("All items")
                    Spacer()
                    Text("\((vm.subjects.count))")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Subjects")
                    Spacer()
                    Text("\(vm.allSubjects)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Interval")
                    Spacer()
                    Text("\(vm.allRecess)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Export Subjects") {
                    try? vm.exportSubjects()
                }
                .disabled((vm.subjects.isEmpty))
                .fileExporter(
                    isPresented: $vm.showSubjectsFileExporter,
                    item: vm.subjectsExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Subjects")
                ) { result in
                    switch result {
                    case .success:
                        vm.subjectsExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        vm.subjectsExportItem = nil
                    }
                } onCancellation: {
                    vm.subjectsExportItem = nil
                }

                Button("Import Subjects") {
                    vm.showSubjectsImportAlert.toggle()
                }
                .alert("Import Subjects?", isPresented: $vm.showSubjectsImportAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Continue") {
                        vm.showSubjectsFileImporter.toggle()
                    }
                } message: {
                    Text("When importing, all existing subjects will be erased. Do you wish to continue?")
                }
                .fileImporter(
                    isPresented: $vm.showSubjectsFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        Task {
                            vm.importedURL = url
                            withAnimation {
                                try? vm.importSubjects()
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }

            Section {
                Button("Delete all subjects") {
                    vm.showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(vm.subjects.isEmpty)
                .alert("Delete all subjects?", isPresented: $vm.showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        try? vm.deleteAllSubjects()
                    }
                }
            }
        }
        .navigationTitle("Subjects")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error!", isPresented: $vm.showErrorMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}
