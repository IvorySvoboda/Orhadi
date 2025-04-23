//
//  DataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 02/04/25.
//

import SwiftData
import SwiftUI

struct DataSettingsView: View {
    @Environment(OrhadiTheme.self) private var theme

    @State private var showEraseDataAlert: Bool = false

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    SubjectsDataSettingsView()
                } label: {
                    Label("Matérias", systemImage: "book.fill")
                }
                NavigationLink {
                    ToDosDataSettingsView()
                } label: {
                    Label("Tarefas", systemImage: "list.clipboard.fill")
                }
                NavigationLink {
                    SRDataSettingsView()
                } label: {
                    Label("Rotina de Estudos", systemImage: "graduationcap.fill")
                }
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button("Apagar todos os dados") {
                    showEraseDataAlert.toggle()
                }.tint(.red)
                .alert(
                    "Apagar todos os dados?",
                    isPresented: $showEraseDataAlert
                ) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        eraseAllData()
                    }
                } message: {
                    Text("Esta ação é permanente e não pode ser desfeita. Tem certeza que deseja continuar?")
                }
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Dados")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func eraseAllData() {
        Task.detached(priority: .background) {
            do {
                let databasePath = URL.documentsDirectory.appending(path: "database.store")
                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Schema(versionedSchema: CurrentSchema.self),
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                let teachers = try context.fetch(FetchDescriptor<Teacher>())
                let subjects = try context.fetch(FetchDescriptor<Subject>())
                let todos = try context.fetch(FetchDescriptor<ToDo>())
                let srsubjects = try context.fetch(FetchDescriptor<SRSubject>())
                let users = try context.fetch(FetchDescriptor<UserProfile>())
                let achievements = try context.fetch(FetchDescriptor<Achievement>())
                let settings = try context.fetch(FetchDescriptor<Settings>())

                for t in teachers { context.delete(t) }
                for sb in subjects { context.delete(sb) }
                for td in todos { context.delete(td) }
                for srsb in srsubjects { context.delete(srsb) }
                for u in users { context.delete(u) }
                for a in achievements { context.delete(a) }
                for s in settings { context.delete(s) }

                context.insert(UserProfile())
                context.insert(Settings())

                try context.save()

                GameManager(context: context).setupAchievementsIfNeeded()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

#Preview("DataSettingsView") {
    NavigationStack {
        DataSettingsView()
    }
}
