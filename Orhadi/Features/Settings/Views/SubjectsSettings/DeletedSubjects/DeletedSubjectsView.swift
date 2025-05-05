//
//  DeletedSubjectsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/05/25.
//

import SwiftUI
import SwiftData

struct DeletedSubjectsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<Subject> { $0.isSubjectDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedSubjects: [Subject]

    @State private var selectedSubjects = Set<Subject>()

    /// Delete Confirmation
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteSelectedConfirmation = false

    // MARK: - Views

    var body: some View {
        List(selection: $selectedSubjects) {
            Section {} footer: {
                Text("As matérias ficam disponíveis aqui por 30 dias. Após esse período, as matérias serão apagadas definitivamente.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(deletedSubjects) { subject in
                    DeletedSubjectRowView(subject: subject)
                        .tag(subject)
                }
                .listRowBackground(Color.orhadiSecondaryBG)
            }
        }
        .orhadiListStyle()
        .navigationTitle("Matérias Apagadas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarBackground(Color.orhadiBG, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(selectedSubjects.isEmpty ? "Restaurar Todas" : "Restaurar") {
                        selectedSubjects.isEmpty ? restoreAllSubjects() : restoreSelectedSubjects()
                    }

                    Spacer()

                    Button(selectedSubjects.isEmpty ? "Apagar Tudo" : "Apagar") {
                        selectedSubjects.isEmpty ? showDeleteAllConfirmation.toggle() : showDeleteSelectedConfirmation.toggle()
                    }
                }.padding(.bottom, 5)
            }
        }
        .confirmationDialog("\(deletedSubjects.count > 1 ? "Estas \(deletedSubjects.count) matérias serão apagadas" : "Esta matéria será apagada"). Esta ação não poderá ser desfeita.", isPresented: $showDeleteAllConfirmation, titleVisibility: .visible, actions: {
            Button("\(deletedSubjects.count > 1 ? "Apagar \(deletedSubjects.count) Matérias" : "Apagar Matéria")", role: .destructive) {
                deleteAllSubjects()
            }
        })
        .confirmationDialog("\(selectedSubjects.count > 1 ? "Estas \(selectedSubjects.count) matérias serão apagadas" : "Esta matéria será apagada"). Esta ação não poderá ser desfeita.", isPresented: $showDeleteSelectedConfirmation, titleVisibility: .visible, actions: {
            Button("\(selectedSubjects.count > 1 ? "Apagar \(selectedSubjects.count) Matérias" : "Apagar Matéria")", role: .destructive) {
                deleteSelectedSubjects()
            }
        })
        .onChange(of: deletedSubjects) { _, newSubjects in
            if newSubjects.isEmpty {
                dismiss()
            }
        }
        .onAppear {
            cleanExpiredSubjects()
        }
    }

    // MARK: - Actions

    private func cleanExpiredSubjects() {
        for subject in deletedSubjects {
            guard let removalDate = Calendar.current.date(byAdding: .day, value: 30, to: subject.deletedAt ?? .now),
                  removalDate <= .now else { continue }

            withTransaction(Transaction(animation: nil)) {
                context.delete(subject)
            }
        }
    }

    private func deleteAllSubjects() {
        for subject in deletedSubjects {
            withAnimation { context.delete(subject) }
        }
    }

    private func deleteSelectedSubjects() {
        for subject in selectedSubjects {
            withAnimation { context.delete(subject) }
        }
        selectedSubjects.removeAll()
    }

    private func restoreAllSubjects() {
        for subject in deletedSubjects {
            restore(subject)
        }
    }

    private func restoreSelectedSubjects() {
        for subject in selectedSubjects {
            restore(subject)
        }
        selectedSubjects.removeAll()
    }

    private func restore(_ subject: Subject) {
        withAnimation {
            subject.isSubjectDeleted = false
            subject.deletedAt = nil
        }
    }
}
