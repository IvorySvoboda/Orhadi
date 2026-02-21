//
//  DataManager.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 27/10/25.
//

import Foundation
import SwiftData
import Combine

final class DataManager {
    var container: ModelContainer
    var context: ModelContext

    private var priveteSettings: Settings?

    var settings: Settings {
        priveteSettings ?? Settings()
    }

    @MainActor
    static let shared = DataManager()

    @MainActor
    private init() {
        do {
            self.container = createContainer()
            self.container.mainContext.autosaveEnabled = false
            self.context = container.mainContext

#if DEBUG
            try SampleDataManager.shared.insertSampleData(in: context)
#endif

            if let settings = try context.fetch(FetchDescriptor<Settings>()).first {
                self.priveteSettings = settings
            } else {
                let newSettings = Settings()
                self.priveteSettings = newSettings
                context.insert(newSettings)
                try save()
            }

            cleanOldDeleted()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: - Subjects

    func fetchSubjects(predicate: Predicate<Subject>? = nil, sortBy: [SortDescriptor<Subject>] = []) -> [Subject] {
        do {
            return try context.fetch(FetchDescriptor<Subject>(predicate: predicate, sortBy: sortBy))
        } catch {
            return []
        }
    }

    func addSubject(_ subject: Subject) throws {
        context.insert(subject)
        try save()
    }

    func editSubject(_ subject: Subject, with draft: DraftSubject) throws {
        subject.name = draft.name.trimmingCharacters(in: .whitespaces)
        subject.teacher = draft.teacher
        subject.schedule = draft.schedule
        subject.startTime = draft.startTime
        subject.endTime = draft.endTime
        subject.place = draft.place.trimmingCharacters(in: .whitespaces)
        try save()
    }

    func softDeleteSubject(_ subject: Subject) throws {
        subject.isSubjectDeleted = true
        subject.deletedAt = .now
        try save()
    }

    func hardDeleteSubject(_ subject: Subject) throws {
        context.delete(subject)
        try save()
    }

    func restoreSubject(_ subject: Subject) throws {
        subject.isSubjectDeleted = false
        subject.deletedAt = nil
        try save()
    }

    func isSubjectScheduleInvalid(_ subject: Subject) -> Bool {
        let subjects = fetchSubjects(predicate: #Predicate { !$0.isSubjectDeleted })

        let sameScheduleSubjects = subjects.filter { other in
            let calendar = Calendar.current
            let otherWeekday = calendar.component(.weekday, from: other.schedule)
            let subjectWeekday = calendar.component(.weekday, from: subject.schedule)

            return otherWeekday == subjectWeekday && other.id != subject.id
        }

        let conflictSubjects = sameScheduleSubjects.filter { other in
            subject.startTime < other.endTime && subject.endTime > other.startTime
        }

        return !conflictSubjects.isEmpty || subject.endTime <= subject.startTime
    }

    // MARK: - To-Dos

    func fetchToDos(predicate: Predicate<ToDo>? = nil, sortBy: [SortDescriptor<ToDo>] = []) -> [ToDo] {
        do {
            return try context.fetch(FetchDescriptor<ToDo>(predicate: predicate, sortBy: sortBy))
        } catch {
            return []
        }
    }

    func addToDo(_ todo: ToDo) throws {
        if settings.scheduleNotifications {
            todo.scheduleNotification()
        }

        if !todo.withHour {
            todo.dueDate = Calendar.current.startOfDay(for: todo.dueDate)
        }

        context.insert(todo)
        try save()
    }

    func editToDo(_ todo: ToDo, with draft: DraftToDo) throws {
        todo.title = draft.title.trimmingCharacters(in: .whitespaces)
        todo.info = draft.info
        todo.dueDate = draft.dueDate
        todo.priority = draft.priority
        todo.withHour = draft.withHour

        /// Se não for uma tarefa nova, atualiza as notificações agendadas.
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

        if !todo.withHour {
            todo.dueDate = Calendar.current.startOfDay(for: todo.dueDate)
        }

        /// Sempre respeitando as preferências do usuário.
        if settings.scheduleNotifications {
            todo.scheduleNotification()
        }

        try save()
    }

    func toggleToDoCompleted(_ todo: ToDo) throws {
        /// Se a to-dos não estiver completada
        if !todo.isCompleted {
            /// completa a tarefa.
            todo.isCompleted = true
            todo.completedAt = .now

            /// remove as notificações agendadas
            NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)
        } else {
            /// descompleta a tarefa.
            todo.isCompleted = false
            todo.completedAt = nil

            /// Agenda as notificações novamente, sempre respeitando as preferências do usuário.
            if settings.scheduleNotifications {
                todo.scheduleNotification()
            }
        }

        try context.save()
    }

    func hardDeleteToDo(_ todo: ToDo) throws {
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)
        context.delete(todo)
        try save()
    }

    func softDelete(_ todo: ToDo) throws {
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)
        todo.isToDoDeleted = true
        todo.deletedAt = .now
        try save()
    }

    func restoreToDo(_ todo: ToDo) throws {
        if !todo.isCompleted, todo.dueDate > .now, !todo.isArchived, settings.scheduleNotifications {
            todo.scheduleNotification()
        }

        todo.isToDoDeleted = false
        todo.deletedAt = nil

        try save()
    }

    func archive(_ todo: ToDo) throws {
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)
        todo.isArchived = true
        try save()
    }

    func unarchive(_ todo: ToDo) throws {
        if !todo.isCompleted, todo.dueDate > .now, settings.scheduleNotifications {
            todo.scheduleNotification()
        }
        todo.isArchived = false
        try save()
    }

    // MARK: - Studies

    func fetchStudies(predicate: Predicate<SRStudy>? = nil, sortBy: [SortDescriptor<SRStudy>] = []) -> [SRStudy] {
        do {
            return try context.fetch(FetchDescriptor<SRStudy>(predicate: predicate, sortBy: sortBy))
        } catch {
            return []
        }
    }

    func addStudy(_ study: SRStudy) throws {
        context.insert(study)
        try save()
    }

    func editStudy(_ study: SRStudy, with draft: DraftStudy) throws {
        study.name = draft.name.trimmingCharacters(in: .whitespaces)
        study.studyDay = draft.studyDay
        study.studyTime = draft.studyTime
        try save()
    }

    func hardDeleteStudy(_ study: SRStudy) throws {
        context.delete(study)
        try save()
    }

    func softDeleteStudy(_ study: SRStudy) throws {
        study.isStudyDeleted = true
        study.deletedAt = .now
        try save()
    }

    func restoreStudy(_ study: SRStudy) throws {
        study.isStudyDeleted = false
        study.deletedAt = nil
        try save()
    }

    func updateStudyLastStudied(_ study: SRStudy) throws {
        study.lastStudied = .now
        try save()
    }

    // MARK: - Teachers

    func fetchTeachers(predicate: Predicate<Teacher>? = nil, sortBy: [SortDescriptor<Teacher>] = []) -> [Teacher] {
        do {
            return try context.fetch(FetchDescriptor<Teacher>(predicate: predicate, sortBy: sortBy))
        } catch {
            return []
        }
    }

    func addTeacher(_ teacher: Teacher) throws {
        context.insert(teacher)
        try save()
    }

    func editTeacher(_ teacher: Teacher, with draft: DraftTeacher) throws {
        teacher.name = draft.name.trimmingCharacters(in: .whitespaces)
        teacher.email = draft.email.trimmingCharacters(in: .whitespaces)
        try save()
    }

    func hardDeleteTeacher(_ teacher: Teacher) throws {
        context.delete(teacher)
        try save()
    }

    // MARK: - Helpers

    func observeContextChanges<T: PersistentModel>(of _: T.Type, _ onChange: @escaping () -> Void) -> AnyCancellable {
        NotificationCenter.default.publisher(for: ModelContext.didSave)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self, let userInfo = notification.userInfo else { return }

                let ids = (userInfo["inserted"] as? [PersistentIdentifier] ?? [])
                + (userInfo["updated"] as? [PersistentIdentifier] ?? [])
                + (userInfo["deleted"] as? [PersistentIdentifier] ?? [])

                for id in ids where self.context.model(for: id) is T {
                    onChange()
                    break
                }
            }
    }

    private func cleanOldDeleted() {
        do {
            let deletedSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                $0.isSubjectDeleted
            }))
            let deletedToDos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                $0.isToDoDeleted
            }))
            let deletedStudies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                $0.isStudyDeleted
            }))

            for deletedSubject in deletedSubjects where deletedSubject.deletedAt?.addingTimeInterval(2_592_000) ?? .distantPast < .now {
                context.delete(deletedSubject)
            }

            for deletedToDo in deletedToDos where deletedToDo.deletedAt?.addingTimeInterval(2_592_000) ?? .distantPast < .now {
                context.delete(deletedToDo)
            }

            for deletedStudy in deletedStudies where deletedStudy.deletedAt?.addingTimeInterval(2_592_000) ?? .distantPast < .now {
                context.delete(deletedStudy)
            }

            try save()
        } catch {
            print(error.localizedDescription)
        }
    }

    func save() throws {
        try context.save()
    }

    // MARK: DEBUG

#if DEBUG
    @MainActor
    func reset(withSampleData: Bool = true) {
        do {
            try cleanContext() /// Clean the `context`

            try container.erase() /// Destroy the `container`

            self.container = createContainer() /// Create a new `container`
            self.container.mainContext.autosaveEnabled = false
            self.context = container.mainContext

            self.priveteSettings = nil

            if withSampleData {
                try SampleDataManager.shared.insertSampleData(in: context)
            }

            if let settings = try context.fetch(FetchDescriptor<Settings>()).first {
                self.priveteSettings = settings
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func cleanContext() throws {
        do {
            fetchSubjects().forEach { context.delete($0) }
            fetchTeachers().forEach { context.delete($0) }
            fetchToDos().forEach { context.delete($0) }
            fetchStudies().forEach { context.delete($0) }

            if let priveteSettings {
                context.delete(priveteSettings)
            }

            try save()
        } catch {
            throw error
        }
    }
#endif
}
