//
//  DataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 02/04/25.
//

import SwiftData
import SwiftUI
import PopupView

struct DataSettingsView: View {

    // MARK: - Properties

    @State private var showEraseDataAlert: Bool = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""

    // MARK: - Views

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
            }.listRowBackground(Color.orhadiSecondaryBG)

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
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Dados")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: errorMessage, { _, _ in
            if !errorMessage.isEmpty {
                showErrorMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    errorMessage = ""
                }
            }
        })
        .popup(isPresented: $showErrorMessage) {
            Text(errorMessage)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 60, leading: 5, bottom: 16, trailing: 5))
                .frame(maxWidth: .infinity)
                .background(Color.red)
        } customize: {
            $0
                .type(.toast)
                .position(.top)
                .animation(.smooth)
                .autohideIn(2)
        }
    }

    // MARK: - Actions

    private func eraseAllData() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let teachers = try context.fetch(FetchDescriptor<Teacher>())
                let subjects = try context.fetch(FetchDescriptor<Subject>())
                let todos = try context.fetch(FetchDescriptor<ToDo>())
                let studies = try context.fetch(FetchDescriptor<SRStudy>())
                let users = try context.fetch(FetchDescriptor<UserProfile>())
                let achievements = try context.fetch(FetchDescriptor<Achievement>())
                let settings = try context.fetch(FetchDescriptor<Settings>())

                for teacher in teachers { context.delete(teacher) }
                for subject in subjects { context.delete(subject) }
                for todo in todos { context.delete(todo) }
                for study in studies { context.delete(study) }
                for user in users { context.delete(user) }
                for achievement in achievements { context.delete(achievement) }
                for setting in settings { context.delete(setting) }

                context.insert(UserProfile())
                context.insert(Settings())

                try context.save()

                GameManager(context: context).setupAchievementsIfNeeded()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
}

#Preview("DataSettingsView") {
    NavigationStack {
        DataSettingsView()
    }
}
