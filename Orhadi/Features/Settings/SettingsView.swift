//
//  SettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 30/03/25.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        SubjectsSettingsView()
                    } label: {
                        Label("Subjects", systemImage: "book.fill")
                    }

                    NavigationLink {
                        ToDosSettingsView()
                    } label: {
                        Label("To-Dos", systemImage: "list.clipboard.fill")
                    }

                    NavigationLink {
                        StudyRoutineSettingsView()
                    } label: {
                        Label("Study Routine", systemImage: "graduationcap.fill")
                    }

                    NavigationLink {
                        TeachersView()
                    } label: {
                        Label("Teachers", systemImage: "person.2.fill")
                    }
                }

                Section {
                    ThemePickerView()
                }

                Section {
                    NavigationLink {
                        DataSettingsView()
                    } label: {
                        Label("Data", systemImage: "square.stack.3d.down.right.fill")
                    }
                }

                Section {
                    HStack {
                        Image("Logo")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Orhadi")
                                .bold()
                            Text("Version: \(AppInfoProvider.appVersion()) (\(AppInfoProvider.appBuild()))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("© Zyvoxi")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowInsets(
                        EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
                    )
                } header: {
                    Text("About")
                }
            }.navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(DataManager.shared.container)
}
