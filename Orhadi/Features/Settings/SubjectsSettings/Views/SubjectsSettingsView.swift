//
//  SubjectsSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/04/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct SubjectsSettingsView: View {
    @State private var viewModel = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                Toggle("Subject indicator", isOn: $viewModel.settings.showCurrentSubjectIndicator)
                    .onChange(of: viewModel.settings.showCurrentSubjectIndicator) { _, _ in
                        viewModel.save()
                    }
            }

            if !viewModel.deletedSubjects.isEmpty {
                Section {
                    NavigationLink("Deleted Subjects") {
                        DeletedSubjectsView()
                    }
                }
            }
        }
        .navigationTitle("Subjects")
        .navigationBarTitleDisplayMode(.inline)
    }
}
