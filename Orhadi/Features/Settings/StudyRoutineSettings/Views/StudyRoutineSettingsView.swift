//
//  StudyRoutineSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/04/25.
//

import SwiftData
import SwiftUI

struct StudyRoutineSettingsView: View {

    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                Picker("Break Time", selection: $vm.settings.breakTime) {
                    ForEach(1..<7, id: \.self) { index in
                        Text("\(5 * index)min").tag(TimeInterval(300 * index))
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: vm.settings.breakTime) { _, _ in
                    vm.save()
                }
            }

            if !vm.deletedStudies.isEmpty {
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
