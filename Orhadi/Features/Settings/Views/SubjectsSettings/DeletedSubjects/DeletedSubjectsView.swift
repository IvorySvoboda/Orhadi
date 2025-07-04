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

    var canShowBottomBar: Bool {
        if #available(iOS 26, *) {
            return false
        } else {
            return true
        }
    }

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
            }.orhadiListRowBackground()
        }
        .orhadiListStyle()
        .navigationTitle("Matérias Apagadas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarBackground(Color.orhadiBG, for: .bottomBar)
        /// BottomBar é apenas para o iOS 18
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        /// Oculta a TabBar no iOS 26+
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && !canShowBottomBar ? .hidden : .visible, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button(selectedSubjects.isEmpty ? "Restaurar Todas" : "Restaurar") {
                    selectedSubjects.isEmpty ? restoreAllSubjects() : restoreSelectedSubjects()
                }

                Spacer()

                Button(selectedSubjects.isEmpty ? "Apagar Tudo" : "Apagar") {
                    selectedSubjects.isEmpty ? showDeleteAllConfirmation.toggle() : showDeleteSelectedConfirmation.toggle()
                }
                .confirmationDialog(
                    "\(deletedSubjects.count > 1 ? "Estas \(deletedSubjects.count) matérias serão apagadas" : "Esta matéria será apagada"). Esta ação não poderá ser desfeita.",
                    isPresented: $showDeleteAllConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        deleteAllSubjects()
                    } label: {
                        Text("\(deletedSubjects.count > 1 ? "Apagar \(deletedSubjects.count) Matérias" : "Apagar Matéria")")
                    }
                }
                .confirmationDialog(
                    "\(selectedSubjects.count > 1 ? "Estas \(selectedSubjects.count) matérias serão apagadas" : "Esta matéria será apagada"). Esta ação não poderá ser desfeita.",
                    isPresented: $showDeleteSelectedConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        deleteSelectedSubjects()
                    } label: {
                        Text("\(selectedSubjects.count > 1 ? "Apagar \(selectedSubjects.count) Matérias" : "Apagar Matéria")")
                    }
                }
            }
        }
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
