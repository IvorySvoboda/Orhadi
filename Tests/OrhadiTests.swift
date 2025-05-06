//
//  OrhadiTests.swift
//  OrhadiTests
//
//  Created by Zyvoxi . on 23/04/25.
//

import Foundation
import SwiftData
import Testing

@testable import Orhadi

struct DataTests {

    // MARK: - Subject & Teacher Tests

    @Test func subjectAndTeacherExportImport() async throws {
        let context = try createTestingContext()

        let sampleData = Subject.sampleData

        var subjects: [Subject]
        var teachers: [Teacher]

        for subject in sampleData { context.insert(subject) }
        try context.save()

        subjects = try context.fetch(FetchDescriptor<Subject>())
        teachers = try context.fetch(FetchDescriptor<Teacher>())

        /// O `sampleData` do `Subject` fornece `4`
        /// "matérias", sendo assim, deve-se existir
        /// um total de `4` "matérias", se não, o
        /// teste para aqui.
        try #require(subjects.count == 4)

        /// Professores devem ser adicionados automaticamente ao adicionar as
        /// matérias com professores != nil

        /// esperamos existir `3` professores pois uma das "matérias"
        /// é um intervalo.
        #expect(teachers.count == 3)

        // MARK: - Teste de Exportação

        let exportItem = SubjectTransferable(subjects: subjects)
        /// Deve conter `4` "matérias" dentro de `exportItem`.
        #expect(exportItem.subjects.count == 4)
        let data = try JSONEncoder().encode(exportItem.subjects)

        // MARK: - Teste de Importação

        /// Decodifica as "matérias" presentes no `data`
        let allSubjects = try JSONDecoder().decode([Subject].self, from: data)
        /// Deve existir um total de `4` "matérias" nas "matérias" importadas
        #expect(allSubjects.count == 4)

        /// Deleta as "matérias" existentes.
        for subject in subjects { context.delete(subject) }
        for subject in allSubjects {
            var teacher: Teacher?

            if let subjectTeacher = subject.teacher {
                let existingTeacher = try context.fetch(
                    FetchDescriptor<Teacher>(
                        predicate: #Predicate { $0.name == subjectTeacher.name }
                    )
                ).first
                /// Como as matérias exportadas estão com os
                /// mesmos professores que estão no banco de
                /// dados, esperamos que existing teacher não
                /// seja nil.
                #expect(existingTeacher != nil)

                /// se o professor da matéria que esta sendo
                /// adicionada já existe no banco de dados, define
                /// `teacher` para o professor existente, se não,
                /// define para o professor que esta na matéria
                /// para que seja adicionado automaticamente no
                /// banco de dados pelo SwiftData.
                if let existingTeacher {
                    teacher = existingTeacher
                } else {
                    teacher = subjectTeacher
                }
            }

            context.insert(
                Subject(
                    name: subject.name,
                    teacher: teacher,
                    schedule: subject.schedule,
                    startTime: subject.startTime,
                    endTime: subject.endTime,
                    isRecess: subject.isRecess
                )
            )
        }
        try context.save()
        /// Atualiza as "matérias" para as mais recentes após a importação
        subjects = try context.fetch(FetchDescriptor<Subject>())
        #expect(subjects.count == 4)

        /// Testamos a importação novamente, so que dessa vez
        /// deletamos os professores para verificar se ele serão
        /// adicionados sozinhos.
        for subject in subjects { context.delete(subject) }
        for teacher in teachers { context.delete(teacher) }
        for subject in allSubjects {
            /// Inserção normal, pois sabemos que aqui não existe
            /// nenhum professor presente no nosso banco de dados.
            context.insert(subject)
        }
        try context.save()
        /// Atualiza as matérias e os professores para os mais recentes após a importação
        subjects = try context.fetch(FetchDescriptor<Subject>())
        teachers = try context.fetch(FetchDescriptor<Teacher>())
        #expect(subjects.count == 4)
        /// esperamos existir `3` professores pois uma das "matérias"
        /// é um intervalo.
        #expect(teachers.count == 3)
    }

    // MARK: - To-Do Tests

    @Test func todoExportImport() async throws {
        let context = try createTestingContext()

        var todos: [ToDo]

        for todo in ToDo.sampleData { context.insert(todo) }
        try context.save()
        todos = try context.fetch(FetchDescriptor<ToDo>())

        /// O `sampleData` do `ToDo` fornece `3`
        /// tarefas, sendo assim, deve-se existir
        /// um total de `3` tarefas, se não, o
        /// teste para aqui.
        try #require(todos.count == 3)

        // MARK: - Teste de Exportação

        let exportItem = ToDoTransferable(todos: todos)
        /// Deve conter `3` tarefas dentro de `exportItem`
        #expect(exportItem.todos.count == 3)
        let data = try JSONEncoder().encode(exportItem.todos)

        // MARK: - Teste de Importação

        /// Decodifica as tarefas presentes no `data`
        let allToDos = try JSONDecoder().decode([ToDo].self, from: data)
        /// Deve existir `3` tarefas nas tarefas importadas
        #expect(allToDos.count == 3)

        /// Remove as tarefas existentes
        for todo in todos { context.delete(todo) }
        /// Insere as tarefas importadas no banco de dados.
        for todo in allToDos { context.insert(todo) }
        try context.save()
        /// Atualiza as tarefas para os mais recentes após a importação
        todos = try context.fetch(FetchDescriptor<ToDo>())
        #expect(todos.count == 3)
    }

    // MARK: SRStudy Tests

    @Test func srStudyExportImport() async throws {
        let context = try createTestingContext()

        var studies: [SRStudy]

        for study in SRStudy.sampleData { context.insert(study) }
        try context.save()
        studies = try context.fetch(FetchDescriptor<SRStudy>())

        /// O `sampleData` do `SRStudy` fornece `3`
        /// estudos, sendo assim, deve-se existir
        /// um total de `3` estudos, se não, o
        /// teste para aqui.
        try #require(studies.count == 3)

        /// Testa a Exportação
        let exportItem = SRStudyTransferable(studies: studies)
        /// Deve conter `3` estudos dentro de `exportItem`.
        #expect(exportItem.studies.count == 3)

        /// Testa a Importação
        for study in studies { context.delete(study) }
        let data = try JSONEncoder().encode(exportItem.studies)
        let allStudies = try JSONDecoder().decode([SRStudy].self, from: data)
        /// Deve existir `3` estudos nos estudos importado.
        #expect(allStudies.count == 3)
        for study in allStudies { context.insert(study) }
        try context.save()
        /// Atualiza os estudos após a importação.
        studies = try context.fetch(FetchDescriptor<SRStudy>())
        #expect(studies.count == 3)
    }
}

private func createTestingContext() throws -> ModelContext {
    let config = ModelConfiguration(
        schema: Schema(versionedSchema: CurrentSchema.self),
        isStoredInMemoryOnly: true
    )
    let container = try ModelContainer(
        for: Schema(versionedSchema: CurrentSchema.self),
        migrationPlan: MigrationPlan.self,
        configurations: config
    )
    return ModelContext(container)
}
