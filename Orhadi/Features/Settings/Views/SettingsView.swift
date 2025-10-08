//
//  SettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 30/03/25.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Bindable var settings: Settings

    var body: some View {
        NavigationStack {
            Form {
                mainSettingsSection

                Section {
                    themePicker
                }
                
                Section {
                    NavigationLink {
                        DataSettingsView()
                    } label: {
                        Label("Data", systemImage: "square.stack.3d.down.right.fill")
                    }
                }
                
#if DEBUG
                Section {
                    NavigationLink {
                        List {
                            Button("Subjects Flood") {
                                for index in 1...999 {
                                    context.insert(Subject(name: "\(index * 1000)", isRecess: index > 500))
                                }
                            }
                            
                            Button("To-Dos Flood") {
                                for index in 1...999 {
                                    context.insert(ToDo(title: "\(index * 1000)", isCompleted: index > 500))
                                }
                            }
                            
                            Button("Studies Flood") {
                                for index in 1...999 {
                                    context.insert(SRStudy(name: "\(index * 1000)"))
                                }
                            }
                        }
                    } label: {
                        Label("Debug", systemImage: "ant.fill")
                    }
                }
#endif // DEBUG

                aboutSection
            }
            .navigationTitle("Settings")
            
        }
    }

    private var mainSettingsSection: some View {
        Section {
            NavigationLink {
                SubjectsSettingsView(settings: settings)
            } label: {
                Label("Subjects", systemImage: "book.fill")
            }
            NavigationLink {
                ToDosSettingsView(settings: settings)
            } label: {
                Label("To-Dos", systemImage: "list.clipboard.fill")
            }
            NavigationLink {
                StudyRoutineSettingsView(settings: settings)
            } label: {
                Label("Study Routine", systemImage: "graduationcap.fill")
            }
            NavigationLink {
                TeachersView()
            } label: {
                Label("Teachers", systemImage: "person.2.fill")
            }
        }
    }

    private var themePicker: some View {
        Picker(selection: $settings.theme) {
            ForEach(Theme.allCases, id: \.self) { theme in
                Text(theme.name).tag(theme.hashValue)
            }
        } label: {
            HStack {
                ZStack {
                    Image(systemName: "circle.righthalf.filled")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color.accentColor)
                        .overlay(
                            Image(systemName: "circle.lefthalf.filled")
                                .resizable()
                                .frame(width: 13, height: 13)
                                .foregroundStyle(Color.accentColor)
                                .background {
                                    Color.orhadiBG
                                        .frame(width: 12, height: 12)
                                        .clipShape(Circle())
                                }
                        )
                }.padding(.trailing, 10)

                Text("Theme")
            }
        }.pickerStyle(.navigationLink)
    }
    
    private var aboutSection: some View {
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
                Spacer()
            }
            .listRowInsets(
                EdgeInsets(
                    top: 5, leading: 10, bottom: 5, trailing: 10))
        } header: {
            Text("About")
        }
    }
}

#Preview {
    SettingsView(settings: Settings())
        .modelContainer(SampleData.shared.container)
}
