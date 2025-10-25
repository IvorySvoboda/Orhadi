//
//  StudyRoutineSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/04/25.
//

import SwiftData
import SwiftUI

struct StudyRoutineSettingsView: View {
    @Query private var studies: [SRStudy]
    @Environment(\.modelContext) private var context
    @Bindable var settings: Settings

    private var deletedStudies: [SRStudy] {
        studies.filter {
            $0.isStudyDeleted
        }
    }

    var body: some View {
        Form {
            Section {
                Picker("Break Time", selection: $settings.breakTime) {
                    ForEach(1..<7, id: \.self) { index in
                        Text("\(5 * index)min").tag(TimeInterval(300 * index))
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: settings.breakTime) { _, _ in
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }

            if !deletedStudies.isEmpty {
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
