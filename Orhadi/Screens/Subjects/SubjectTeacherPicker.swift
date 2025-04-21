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
    @Environment(OrhadiTheme.self) private var theme

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
            }.listRowBackground(theme.secondaryBGColor())

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
            }.listRowBackground(theme.secondaryBGColor())

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
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Professor")
        .navigationBarTitleDisplayMode(.inline)
    }
}
