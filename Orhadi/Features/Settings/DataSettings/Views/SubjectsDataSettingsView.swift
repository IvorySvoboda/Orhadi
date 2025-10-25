//
//  SubjectsDataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import SwiftUI
import PopupView

struct SubjectsDataSettingsView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ViewModel()

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("All items")
                    Spacer()
                    Text("\((viewModel.subjects.count))")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Subjects")
                    Spacer()
                    Text("\(viewModel.allSubjects)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Interval")
                    Spacer()
                    Text("\(viewModel.allRecess)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Export Subjects") {
                    viewModel.exportSubjects()
                }
                .disabled((viewModel.subjects.isEmpty))
                .fileExporter(
                    isPresented: $viewModel.showSubjectsFileExporter,
                    item: viewModel.subjectsExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Subjects")
                ) { result in
                    switch result {
                    case .success:
                        viewModel.subjectsExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        viewModel.subjectsExportItem = nil
                    }
                } onCancellation: {
                    viewModel.subjectsExportItem = nil
                }

                Button("Import Subjects") {
                    viewModel.showSubjectsImportAlert.toggle()
                }
                .alert("Import Subjects?", isPresented: $viewModel.showSubjectsImportAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Continue") {
                        viewModel.showSubjectsFileImporter.toggle()
                    }
                } message: {
                    Text("When importing, all existing subjects will be erased. Do you wish to continue?")
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
            }

            Section {
                Button("Delete all subjects") {
                    viewModel.showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(viewModel.subjects.isEmpty)
                .alert("Delete all subjects?", isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        viewModel.deleteAllSubjects()
                    }
                }
            }
        }
        .navigationTitle("Subjects")
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
            viewModel.fetchSubjects()
        }
        .onAppear {
            if viewModel.context == nil {
                viewModel.context = context
                viewModel.fetchSubjects()
            }
        }
    }
}
