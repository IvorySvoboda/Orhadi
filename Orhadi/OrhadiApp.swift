//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI

typealias CurrentSchema = OrhadiSchemaV1
typealias Subject = CurrentSchema.Subject
typealias SRStudy = CurrentSchema.SRStudy
typealias ToDo = CurrentSchema.ToDo
typealias Settings = CurrentSchema.Settings
typealias Teacher = CurrentSchema.Teacher
typealias UserProfile = CurrentSchema.UserProfile
typealias Achievement = CurrentSchema.Achievement

@main
struct OrhadiApp: App {
    /// Cria o container do SwiftData
    var container: ModelContainer {
        do {
            return try createContainer()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }.modelContainer(container)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [Settings]
    @Query private var userProfile: [UserProfile]

    var body: some View {
        ContentView()
            .onAppear {
                /// Verifica se `settings` e `userProfile` é nil, se for, insere eles no context.
                if settings.first == nil {
                    modelContext.insert(Settings())
                }
                if userProfile.first == nil {
                    modelContext.insert(UserProfile())
                }

                /// Solicita permissão para as notificações
                NotificationsManager.shared.requestNotificationAuthorization()

                /// Apagas itens apagados a mais de 30 dias
                cleanOldDeleted()
            }
            .environment(settings.first ?? Settings())
            .environment(userProfile.first ?? UserProfile())
            .environment(GameManager(context: modelContext))
    }

    private func cleanOldDeleted() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let deletedSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                    $0.isSubjectDeleted
                }))
                let deletedToDos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                    $0.isToDoDeleted
                }))
                let deletedStudies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                    $0.isStudyDeleted
                }))

                let calendar = Calendar.current

                for deletedSubject in deletedSubjects where (calendar.date(byAdding: .day, value: 30, to: deletedSubject.deletedAt!) ?? Date()) < .now {
                    context.delete(deletedSubject)
                }

                for deletedToDo in deletedToDos where (calendar.date(byAdding: .day, value: 30, to: deletedToDo.deletedAt!) ?? Date()) < .now {
                    context.delete(deletedToDo)
                }

                for deletedStudy in deletedStudies where (calendar.date(byAdding: .day, value: 30, to: deletedStudy.deletedAt!) ?? Date()) < .now {
                    context.delete(deletedStudy)
                }

                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
