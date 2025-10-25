//
//  DataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 02/04/25.
//

import SwiftData
import SwiftUI
import PopupView

struct DataSettingsView: View {

    @State private var viewModel = ViewModel()

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
                            viewModel.eraseAllData()
                        }
                    } message: {
                        Text("All data, including subjects, to-dos, and studies, will be deleted. It will not be possible to recover the data after resetting. Are you sure you want to continue?")
                    }
            }
        }
        .navigationTitle("Data")
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
    }
}

#Preview("DataSettingsView") {
    NavigationStack {
        DataSettingsView()
    }
}
