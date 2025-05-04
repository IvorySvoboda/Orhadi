//
//  StudyRoutineSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftData
import SwiftUI

struct StudyRoutineSettingsView: View {

    @Query private var studies: [SRStudy]

    @Bindable var settings: Settings

    private var deletedStudies: [SRStudy] {
        studies.filter {
            $0.isStudyDeleted
        }
    }

    var body: some View {
        Form {
            Section {
                BreakTimePickerView()
            }.listRowBackground(Color.orhadiSecondaryBG)

            if !deletedStudies.isEmpty {
                Section {
                    NavigationLink {
                        DeletedStudyView()
                    } label: {
                        Text("Estudos Apagados")
                    }
                }.listRowBackground(Color.orhadiSecondaryBG)
            }
        }
        .orhadiListStyle()
        .navigationTitle("Rotina de Estudos")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct DeletedStudyView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<SRStudy> { $0.isStudyDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedStudies: [SRStudy]

    @State private var selectedStudies = Set<SRStudy>()
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteSelectedConfirmation = false

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
                .listRowBackground(Color.orhadiSecondaryBG)
            }
        }
        .orhadiListStyle()
        .navigationTitle("Estudos Apagados")
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
                    Button(selectedStudies.isEmpty ? "Restaurar Todos" : "Restaurar") {
                        selectedStudies.isEmpty ? restoreAllStudies() : restoreSelectedStudies()
                    }

                    Spacer()

                    Button(selectedStudies.isEmpty ? "Apagar Tudo" : "Apagar") {
                        selectedStudies.isEmpty ? (showDeleteAllConfirmation = true) : (showDeleteSelectedConfirmation = true)
                    }
                }.padding(.bottom, 5)
            }
        }
        .confirmationDialog("\(deletedStudies.count > 1 ? "Estes \(deletedStudies.count) estudos serão apagados" : "Este estudo será apagado"). Esta ação não poderá ser desfeita.", isPresented: $showDeleteAllConfirmation, titleVisibility: .visible, actions: {
            Button("\(deletedStudies.count > 1 ? "Apagar \(deletedStudies.count) Estudos" : "Apagar Estudo")", role: .destructive) {
                deleteAllStudies()
            }
        })
        .confirmationDialog("\(selectedStudies.count > 1 ? "Estes \(selectedStudies.count) estudos serão apagados" : "Este estudo será apagado"). Esta ação não poderá ser desfeita.", isPresented: $showDeleteSelectedConfirmation, titleVisibility: .visible, actions: {
            Button("\(selectedStudies.count > 1 ? "Apagar \(selectedStudies.count) Estudos" : "Apagar Estudo")", role: .destructive) {
                deleteSelectedStudies()
            }
        })
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

struct DeletedStudyRowView: View {
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false

    let study: SRStudy

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(study.name.nilIfEmpty() ?? "Sem Nome")
                    .font(.headline)
                    .lineLimit(1)

                CustomLabel("\(study.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Apagar", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }.tint(.red)

            Button(role: .destructive) {
                recoverStudy()
            } label: {
                Label("Recuperar", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }.tint(.indigo)
        }
        .confirmationDialog("Este estudo será apagado. Esta ação não poderá ser desfeita.",
                            isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Apagar Estudo", role: .destructive) {
                withAnimation {
                    context.delete(study)
                }
            }
        }
    }

    private func recoverStudy() {
        withAnimation {
            study.isStudyDeleted = false
            study.deletedAt = nil
        }
    }
}
