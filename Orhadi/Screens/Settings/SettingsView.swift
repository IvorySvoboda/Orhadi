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
    @Environment(\.modelContext) private var modelContext

    @State private var isErasing: Bool = false
    @State private var showEraseDataAlert: Bool = false

    @Bindable var settings: Settings

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .foregroundStyle(Color.secondary)
                            VStack(alignment: .leading , spacing: 5) {
                                Text("Usuario")
                                    .font(.headline)
                                Text("Level: 1")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                        }.frame(height: 50)
                    }
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

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
                        Label(
                            "Rotina de Estudos",
                            systemImage: "graduationcap.fill")
                    }
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    Picker("Tema", selection: $settings.theme) {
                        Text("Auto").tag(Theme.auto)
                        Text("Claro").tag(Theme.light)
                        Text("Escuro").tag(Theme.dark)
                    }
                } header: {
                    Text("Aparência")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    NavigationLink("Dados") {
                        DataSettingsView()
                    }

                    Button("Apagar Dados") {
                        showEraseDataAlert.toggle()
                    }
                    .disabled(isErasing)
                    .alert(
                        "Apagar todos os dados?",
                        isPresented: $showEraseDataAlert
                    ) {
                        Button("Cancelar", role: .cancel) {}
                        Button("Apagar", role: .destructive) {
                            eraseAllData()
                        }
                    } message: {
                        Text(
                            "Esta ação é permanente e não pode ser desfeita. Tem certeza que deseja continuar?"
                        )
                    }

                } header: {
                    Text("Dados")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    HStack {
                        Image("Logo")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 15, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Orhadi")
                                .bold()
                            Text("Versão: \(AppInfoProvider.appVersion()) (\(AppInfoProvider.appBuild()))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("© Zyvoxi Industries")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }.padding(.vertical, 5)
                        Spacer()
                    }
                    .listRowInsets(
                        EdgeInsets(
                            top: 10, leading: 10, bottom: 10, trailing: 10))
                } header: {
                    Text("Sobre")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle("Ajustes")
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme),
                for: .navigationBar)

        }
    }

    @MainActor
    private func eraseAllData() {
        do {
            let subjects = try modelContext.fetch(FetchDescriptor<Subject>())
            let todos = try modelContext.fetch(FetchDescriptor<ToDo>())
            let srsubjects = try modelContext.fetch(
                FetchDescriptor<SRSubject>())

            for subject in subjects { modelContext.delete(subject) }
            for todo in todos {
                let todoID = todo.id
                let identifiers = [
                    "\(todoID)-1h",
                    "\(todoID)-24h",
                    "\(todoID)-due",
                ]

                NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                debugPrint("Notificações desabilitadas para: \(todo.title)")

                modelContext.delete(todo)
            }
            for subject in srsubjects { modelContext.delete(subject) }

            try modelContext.delete(model: Settings.self)
            modelContext.insert(Settings())
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ProfileView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(GameManager.self) private var game
    @Environment(UserProfile.self) private var user

    @State private var minY: Int = 150

    var body: some View {
        List {
            Section {
                GeometryReader { geo in
                    let currentMinY = geo.frame(in: .global).minY

                    HStack() {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(Color.secondary)
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Level: \(user.level)")
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                            Spacer()
                        }
                        Spacer()
                    }
                    .onChange(of: currentMinY) { _, _ in
                        withAnimation(.smooth(duration: 0.25)) {
                            minY = Int(currentMinY)
                        }
                    }
                }.frame(height: 140)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)

            NavigationLink("Conquistas") {
                AchievementView()
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            Section {
                HStack {
                    Text("XP:")
                    Spacer()
                    Text("\(user.xp)/\(game.xpRequired(for: user.level))")
                }
                HStack {
                    Text("Tempo estudado:")
                    Spacer()
                    Text(formatTime(user.timeStudied))
                }
            }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(OrhadiTheme.getBGColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(user.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .opacity(minY < -10 ? 1 : 0)
            }
        }
        .toolbarBackground(OrhadiTheme.getBGColor(for: colorScheme), for: .navigationBar)
    }
}

struct AchievementView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(GameManager.self) private var game

    @Query private var achievements: [Achievement]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State private var selectedAchievement: Int? = nil

    var body: some View {
        ZStack {
            OrhadiTheme.getBGColor(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(achievements) { achievement in
                        VStack(spacing: 15) {
                            ZStack {
                                Image(systemName: achievement.imageName)
                                    .font(.system(size: 60))
                                    .foregroundStyle(OrhadiTheme.getBGColor(for: colorScheme))
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)
                                            .frame(width: 80, height: 80)
                                            .opacity(achievement.isUnlocked ? 1 : 0.4)
                                    )
                                if !achievement.isUnlocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(Color.gray)
                                        .shadow(radius: 15)
                                }
                            }
                            Text(achievement.isUnlocked ? achievement.name : "…")
                                .font(.subheadline)
                                .opacity(achievement.isUnlocked ? 1 : 0.5)
                        }
                    }
                }.padding()
            }
        }
        .navigationTitle("Conquistas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(OrhadiTheme.getBGColor(for: colorScheme), for: .navigationBar)
    }
}

#Preview {
    SettingsView(settings: Settings())
        .modelContainer(SampleData.shared.container)
}
