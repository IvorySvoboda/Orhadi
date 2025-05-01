//
//  SettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/03/25.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(UserProfile.self) private var user

    @Bindable var settings: Settings

    var body: some View {
        NavigationStack {
            Form {
                userProfileSection

                mainSettingsSection

                Section {
                    ThemePickerView()
                }.listRowBackground(Color.orhadiSecondaryBG)

                Section {
                    NavigationLink {
                        DataSettingsView()
                    } label: {
                        Label("Dados", systemImage: "square.stack.3d.down.right.fill")
                    }
                }.listRowBackground(Color.orhadiSecondaryBG)

                aboutSection
            }
            .navigationTitle("Ajustes")
            .orhadiListStyle()
        }
    }

    private var userProfileSection: some View {
        Section {
            NavigationLink {
                ProfileView()
            } label: {
                HStack {
                    if let userPhoto = user.photo, let uiImage = UIImage(data: userPhoto) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipped(antialiased: true)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundStyle(.tint)
                    }
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text("Level: \(user.level)")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }.frame(height: 40)
            }
        }.listRowBackground(Color.orhadiSecondaryBG)
    }

    private var mainSettingsSection: some View {
        Section {
            NavigationLink {
                SubjectsSettingsView(settings: settings)
            } label: {
                Label("Matérias", systemImage: "book.fill")
            }
            NavigationLink {
                ToDosSettingsView(settings: settings)
            } label: {
                Label("Tarefas", systemImage: "list.clipboard.fill")
            }
            NavigationLink {
                StudyRoutineSettingsView(settings: settings)
            } label: {
                Label("Rotina de Estudos", systemImage: "graduationcap.fill")
            }
            NavigationLink {
                TeachersView()
            } label: {
                Label("Professores", systemImage: "person.2.fill")
            }
        }.listRowBackground(Color.orhadiSecondaryBG)
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
                    Text("Versão: \(AppInfoProvider.appVersion()) (\(AppInfoProvider.appBuild()))")
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
            Text("Sobre")
        }.listRowBackground(Color.orhadiSecondaryBG)
    }
}

#Preview {
    SettingsView(settings: Settings())
        .modelContainer(SampleData.shared.container)
        .environment(UserProfile())
        .environment(GameManager(context: SampleData.shared.context))
}
