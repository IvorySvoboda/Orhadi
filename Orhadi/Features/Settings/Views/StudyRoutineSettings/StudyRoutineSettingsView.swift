//
//  StudyRoutineSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftData
import SwiftUI

struct StudyRoutineSettingsView: View {

    @Query private var studies: [SRStudy]

    @Bindable var settings: Settings

    private var deletedStudies: [SRStudy] {
        studies.filter {
            $0.isStudyDeleted
        }
    }

    var body: some View {
        Form {
            Section {
                BreakTimePickerView()
            }.listRowBackground(Color.orhadiSecondaryBG)

            if !deletedStudies.isEmpty {
                Section {
                    NavigationLink {
                        DeletedStudiesView()
                    } label: {
                        Text("Estudos Apagados")
                    }
                }.listRowBackground(Color.orhadiSecondaryBG)
            }
        }
        .orhadiListStyle()
        .navigationTitle("Rotina de Estudos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
