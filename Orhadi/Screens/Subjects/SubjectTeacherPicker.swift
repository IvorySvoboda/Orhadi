//
//  SubjectTeacherPicker.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftData
import SwiftUI

struct SubjectTeacherPicker: View {
    @Environment(\.colorScheme) private var colorScheme

    @Query private var teachers: [Teacher]

    @Bindable var subject: Subject

    var body: some View {
        NavigationLink {
            List {
                Section {
                    ForEach(teachers) { teacher in
                        Button {
                            withAnimation(.smooth(duration: 0.1)) {
                                subject.teacher = teacher
                            }
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
            }
            .navigationTitle("Professor")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(OrhadiTheme.getBGColor(for: colorScheme))
        } label: {
            HStack {
                Text("Professor")
                Spacer()
                Text(subject.teacher?.name ?? "Nenhum")
                    .foregroundColor(.secondary)
            }
        }
    }
}
