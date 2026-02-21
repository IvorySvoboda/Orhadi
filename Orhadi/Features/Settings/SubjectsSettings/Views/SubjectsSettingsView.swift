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
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                Toggle("Subject indicator", isOn: $vm.settings.showCurrentSubjectIndicator)
                    .onChange(of: vm.settings.showCurrentSubjectIndicator) { _, _ in
                        vm.save()
                    }
            }

            if !vm.deletedSubjects.isEmpty {
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
