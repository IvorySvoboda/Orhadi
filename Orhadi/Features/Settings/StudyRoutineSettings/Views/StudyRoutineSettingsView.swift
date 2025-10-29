//
//  StudyRoutineSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/04/25.
//

import SwiftData
import SwiftUI

struct StudyRoutineSettingsView: View {

    @State private var viewModel = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                Picker("Break Time", selection: $viewModel.settings.breakTime) {
                    ForEach(1..<7, id: \.self) { index in
                        Text("\(5 * index)min").tag(TimeInterval(300 * index))
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: viewModel.settings.breakTime) { _, _ in
                    viewModel.save()
                }
            }

            if !viewModel.deletedStudies.isEmpty {
                Section {
                    NavigationLink("Deleted Studies") {
                        DeletedStudiesView()
                    }
                }
            }
        }
        .navigationTitle("Study Routine")
        .navigationBarTitleDisplayMode(.inline)
    }
}
