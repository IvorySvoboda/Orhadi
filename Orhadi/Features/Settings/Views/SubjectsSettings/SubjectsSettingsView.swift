//
//  SubjectsSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI
import SwiftData

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
            if !deletedSubjects.isEmpty {
                Section {
                    NavigationLink {
                        DeletedSubjectsView()
                    } label: {
                        Text("Matérias Apagadas")
                    }
                }.listRowBackground(Color.orhadiSecondaryBG)
            }
        }
        .orhadiListStyle()
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
    }
}
