//
//  SubjectsSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 01/04/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct SubjectsSettingsView: View {

    @Query private var subjects: [Subject]

    @Bindable var settings: Settings

    private var deletedSubjects: [Subject] {
        subjects.filter {
            $0.isSubjectDeleted
        }
    }

    var body: some View {
        Form {
            Section {
                Toggle("Subject indicator", isOn: $settings.showCurrentSubjectIndicator)
                    .onChange(of: settings.showCurrentSubjectIndicator) { _, _ in
                        WidgetCenter.shared.reloadAllTimelines()
                    }
            }

            if !deletedSubjects.isEmpty {
                Section {
                    NavigationLink {
                        DeletedSubjectsView()
                    } label: {
                        Text("Deleted Subjects")
                    }
                }
            }
        }
        .navigationTitle("Subjects")
        .navigationBarTitleDisplayMode(.inline)
    }
}
