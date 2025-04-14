//
//  SubjectsSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI
import SwiftData

struct SubjectsSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle("Confirmar para Excluir", isOn: $settings.subjectsDeleteConfirmation)
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            Section {
                NavigationLink("Professores") {
                    TeachersView()
                }
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .background(OrhadiTheme.getBGColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBGColor(for: colorScheme),
            for: .navigationBar)
    }
}

struct TeachersView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context

    @Query private var teachers: [Teacher]

    @State private var isAdding: Bool = false

    var body: some View {
        List(teachers) { teacher in
            VStack(alignment: .leading) {
                Text(teacher.name)
                    .font(.headline)
                Text(teacher.email)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    context.insert(Teacher(name: "Teacher", email: "email@exemple.com"))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .background(OrhadiTheme.getBGColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Professores")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBGColor(for: colorScheme),
            for: .navigationBar)
    }
}
