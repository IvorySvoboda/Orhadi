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

    @State private var id: UUID = UUID()
    @State private var isErasing: Bool = false
    @State private var showEraseDataAlert: Bool = false

    @Bindable var settings: Settings

    var body: some View {
        NavigationStack {
            Form {
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

                    Picker(
                        "Cor de Destaque", selection: $settings.accentColor
                    ) {
                        Text("Azul (padrão)").tag(0)
                        Text("Verde").tag(1)
                        Text("Vermelho").tag(2)
                        Text("Roxo").tag(3)
                        Text("Laranja").tag(4)
                        Text("Índigo").tag(5)
                        Text("Ciano").tag(6)
                        Text("Amarelo").tag(7)
                        Text("Rosa").tag(8)
                    }
                    .onChange(of: settings.accentColor) {
                        id = UUID()
                    }
                } header: {
                    Text("Aparência")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    Toggle(isOn: $settings.swipeActions) {
                        Label("Ações de arraste", systemImage: "hand.draw.fill")
                    }
                    .help("Deslize itens para a esquerda ou direita para executar ações rapidamente.")
                    .tint(.green)
                    .onChange(of: settings.swipeActions) { _, newValue in
                        guard !newValue && !settings.editButton else {
                            return
                        }
                        settings.editButton = true
                    }

                    Toggle(isOn: $settings.editButton) {
                        Label("Botão de Editar", systemImage: "pencil")
                    }
                    .help("Adiciona um botão de edição na barra de ferramentas.")
                    .tint(.green)
                    .onChange(of: settings.editButton) { _, newValue in
                        guard !newValue && !settings.swipeActions else {
                            return
                        }
                        settings.swipeActions = true
                    }
                } header: {
                    Text("Interação")
                } footer: {
                    Text("Essas configurações alteram a forma de interagir com os itens da interface.")
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
                            let version = AppInfoProvider.appVersion()
                            let build = AppInfoProvider.appBuild()

                            Text("Orhadi")
                                .bold()
                            Text("Versão: \(version) (\(build))")
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
            .background(OrhadiTheme.getBackgroundColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle("Ajustes")
            .toolbarBackground(
                OrhadiTheme.getBackgroundColor(for: colorScheme),
                for: .navigationBar)

        }.id(id)
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

#Preview {
    SettingsView(settings: Settings())
        .modelContainer(SampleData.shared.container)
}
