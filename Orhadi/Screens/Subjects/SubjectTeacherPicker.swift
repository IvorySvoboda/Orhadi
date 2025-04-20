//
//  SubjectTeacherPicker.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftData
import SwiftUI

struct SubjectTeacherPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @Query(sort: \Teacher.name, animation: .smooth) private var teachers: [Teacher]

    @Bindable var subject: Subject

    @State private var showAddSheet: Bool = false

    // MARK: - Views

    var body: some View {
        List {
            Section {
                ForEach(teachers) { teacher in
                    Button {
                        withAnimation(.smooth(duration: 0.1)) {
                            subject.teacher = teacher
                        }
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(teacher.name)
                                    .font(.headline)
                            }
                            Spacer()
                            if subject.teacher == teacher {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }.tint(colorScheme == .dark ? .white : .black)
                }
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            Section {
                Button {
                    withAnimation(.smooth(duration: 0.1)) {
                        subject.teacher = nil
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text("Nenhum")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        if subject.teacher == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(colorScheme == .dark ? .white : .black)
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            Section {
                Button {
                    showAddSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundStyle(.secondary)
                        Text("Novo Professor")
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.secondary)
                .sheet(isPresented: $showAddSheet) {
                    TeacherAddView()
                        .interactiveDismissDisabled()
                }
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .navigationTitle("Professor")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(OrhadiTheme.getBGColor(for: colorScheme))
    }
}
