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
    @Environment(UserProfile.self) private var user
    @Environment(OrhadiTheme.self) private var theme

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
                }.listRowBackground(theme.secondaryBGColor())

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
                }.listRowBackground(theme.secondaryBGColor())

                Section {
                    Picker("Tema", selection: $settings.theme) {
                        Text("Auto").tag(Theme.auto)
                        Text("Claro").tag(Theme.light)
                        Text("Escuro").tag(Theme.dark)
                    }
                } header: {
                    Text("Aparência")
                }.listRowBackground(theme.secondaryBGColor())

                Section {
                    NavigationLink("Dados") {
                        DataSettingsView()
                    }

                    Button("Apagar Dados") {
                        showEraseDataAlert.toggle()
                    }
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
                }.listRowBackground(theme.secondaryBGColor())

                Section {
                    HStack {
                        ZStack {
                            Image("Logo")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .colorMultiply(.black)
                                .opacity(colorScheme == .dark ? 0 : 0.5)

                            Image("Logo")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .opacity(0.5)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Orhadi")
                                .bold()
                            Text("Versão: \(AppInfoProvider.appVersion()) (\(AppInfoProvider.appBuild()))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("© Zyvoxi Industries")
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
                }.listRowBackground(theme.secondaryBGColor())
            }
            .modifier(DefaultList())
            .navigationTitle("Ajustes")
        }
    }

    @MainActor
    private func eraseAllData() {
        do {
            let subjects = try modelContext.fetch(FetchDescriptor<Subject>())
            let todos = try modelContext.fetch(FetchDescriptor<ToDo>())
            let teachers = try modelContext.fetch(FetchDescriptor<Teacher>())
            let achievements = try modelContext.fetch(FetchDescriptor<Achievement>())

            for subject in subjects {

                subject.teacher = nil

                try! modelContext.save()

                modelContext.delete(subject)
            }
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
            for teacher in teachers { modelContext.delete(teacher) }
            for achievement in achievements { modelContext.delete(achievement) }

            try modelContext.delete(model: Settings.self)
            try modelContext.delete(model: UserProfile.self)

            modelContext.insert(Settings())
            modelContext.insert(UserProfile())
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    SettingsView(settings: Settings())
        .modelContainer(SampleData.shared.container)
        .environment(UserProfile())
        .environment(GameManager(context: SampleData.shared.context))
}
