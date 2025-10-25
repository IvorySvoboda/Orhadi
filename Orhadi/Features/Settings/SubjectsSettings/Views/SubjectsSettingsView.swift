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
    @Query private var subjects: [Subject]
    @Environment(\.modelContext) private var context
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
                        do {
                            try context.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
            }

            if !deletedSubjects.isEmpty {
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
