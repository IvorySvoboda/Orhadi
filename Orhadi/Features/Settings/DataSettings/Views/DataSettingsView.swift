//
//  DataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 02/04/25.
//

import SwiftData
import SwiftUI

struct DataSettingsView: View {
    @State private var viewModel = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    SubjectsDataSettingsView()
                } label: {
                    Label("Subjects", systemImage: "book.fill")
                }
                NavigationLink {
                    ToDosDataSettingsView()
                } label: {
                    Label("To-Dos", systemImage: "list.clipboard.fill")
                }
                NavigationLink {
                    SRDataSettingsView()
                } label: {
                    Label("Study Routine", systemImage: "graduationcap.fill")
                }
            }

            Section {
                Button("Reset all data") {
                    viewModel.showEraseDataAlert.toggle()
                }.tint(.red)
                    .alert(
                        "Reset all data?",
                        isPresented: $viewModel.showEraseDataAlert
                    ) {
                        Button("Cancel", role: .cancel) {}
                        Button("Reset", role: .destructive) {
                            try? viewModel.eraseAllData()
                        }
                    } message: {
                        Text("All data, including subjects, to-dos, and studies, will be deleted. It will not be possible to recover the data after resetting. Are you sure you want to continue?")
                    }
            }
        }
        .navigationTitle("Data")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error!", isPresented: $viewModel.showErrorMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview("DataSettingsView") {
    NavigationStack {
        DataSettingsView()
    }
}
