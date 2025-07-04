//
//  DeletedStudyView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/05/25.
//

import SwiftUI
import SwiftData

struct DeletedStudiesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<SRStudy> { $0.isStudyDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedStudies: [SRStudy]

    @State private var selectedStudies = Set<SRStudy>()

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
        List(selection: $selectedStudies) {
            Section {} footer: {
                Text("Os estudos ficam disponíveis aqui por 30 dias. Após esse período, os estudos serão apagados definitivamente.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(deletedStudies) { study in
                    DeletedStudyRowView(study: study)
                        .tag(study)
                }
                .orhadiListRowBackground()
            }
        }
        .orhadiListStyle()
        .navigationTitle("Estudos Apagados")
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
//                HStack {
                    Button(selectedStudies.isEmpty ? "Restaurar Todos" : "Restaurar") {
                        selectedStudies.isEmpty ? restoreAllStudies() : restoreSelectedStudies()
                    }

                    Spacer()

                    Button(selectedStudies.isEmpty ? "Apagar Tudo" : "Apagar") {
                        selectedStudies.isEmpty ? showDeleteAllConfirmation.toggle() : showDeleteSelectedConfirmation.toggle()
                    }
                    .confirmationDialog(
                        "\(deletedStudies.count > 1 ? "Estes \(deletedStudies.count) estudos serão apagados" : "Este estudo será apagado"). Esta ação não poderá ser desfeita.",
                        isPresented: $showDeleteAllConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button(role: .destructive) {
                            deleteAllStudies()
                        } label: {
                            Text("\(deletedStudies.count > 1 ? "Apagar \(deletedStudies.count) Estudos" : "Apagar Estudo")")
                        }
                    }
                    .confirmationDialog(
                        "\(selectedStudies.count > 1 ? "Estes \(selectedStudies.count) estudos serão apagados" : "Este estudo será apagado"). Esta ação não poderá ser desfeita.",
                        isPresented: $showDeleteSelectedConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button(role: .destructive) {
                            deleteSelectedStudies()
                        } label: {
                            Text("\(selectedStudies.count > 1 ? "Apagar \(selectedStudies.count) Estudos" : "Apagar Estudo")")
                        }
                    }
//                }.padding(.bottom, 5)
            }
        }
        .onChange(of: deletedStudies) { _, newStudies in
            if newStudies.isEmpty {
                dismiss()
            }
        }
        .onAppear {
            cleanExpiredStudies()
        }
    }

    // MARK: - Actions

    private func cleanExpiredStudies() {
        for study in deletedStudies {
            guard let removalDate = Calendar.current.date(byAdding: .day, value: 30, to: study.deletedAt ?? .now),
                  removalDate <= .now else { continue }

            withTransaction(Transaction(animation: nil)) {
                context.delete(study)
            }
        }
    }

    private func deleteAllStudies() {
        for study in deletedStudies {
            withAnimation { context.delete(study) }
        }
    }

    private func deleteSelectedStudies() {
        for study in selectedStudies {
            withAnimation { context.delete(study) }
        }
        selectedStudies.removeAll()
    }

    private func restoreAllStudies() {
        for study in deletedStudies {
            restore(study)
        }
    }

    private func restoreSelectedStudies() {
        for study in selectedStudies {
            restore(study)
        }
        selectedStudies.removeAll()
    }

    private func restore(_ study: SRStudy) {
        withAnimation {
            study.isStudyDeleted = false
            study.deletedAt = nil
        }
    }
}
