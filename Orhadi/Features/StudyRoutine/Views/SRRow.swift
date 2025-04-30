//
//  SRRow.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct SRRow: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    @State private var showDeleteConfirmation: Bool = false

    var study: SRStudy
    @Binding var studiesToStudy: [SRStudy]
    @Binding var navigateToStudyingView: Bool
    @Binding var studyToAdd: SRStudy?
    @Binding var studyToEdit: SRStudy?

    // MARK: - Views

    var body: some View {
        HStack {
            if study.hasStudiedThisWeek {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }

            Text(study.name.nilIfEmpty() ?? "Sem Nome")
                .lineLimit(1)
                .frame(maxWidth: 200, alignment: .leading)

            Spacer()

            Text(study.studyTime.formatToHour())
                .bold()
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            startStudySwipeAction
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteSwipeAction
            duplicateSwipeAction
            editSwipeAction
        }
        .alert("Deletar Estudo?", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Deletar", role: .destructive) {
                deleteStudy()
            }
        } message: {
            Text("Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir esta matéria dos estudos?")
        }
    }

    // MARK: Swipe Actions

    private var startStudySwipeAction: some View {
        Button {
            studiesToStudy = [study]
            navigateToStudyingView.toggle()
        } label: {
            Label("Iniciar", systemImage: "play.circle.fill")
        }.tint(.accentColor)
    }

    private var deleteSwipeAction: some View {
        Group {
            /// Cria o botão adequado para as configurações do usuário.
            if settings.studyDeleteConfirmation {
                Button {
                    showDeleteConfirmation.toggle()
                } label: {
                    Image(systemName: "trash.fill")
                }.tint(.red)
            } else {
                Button(role: .destructive) {
                    deleteStudy()
                } label: {
                    Image(systemName: "trash.fill")
                }
            }
        }
    }

    private var duplicateSwipeAction: some View {
        Button {
            studyToAdd = study
        } label: {
            Image(systemName: "rectangle.fill.on.rectangle.angled.fill")
        }.tint(.teal)
    }

    private var editSwipeAction: some View {
        Button {
            studyToEdit = study
        } label: {
            Image(systemName: "pencil")
        }.tint(.accentColor)
    }

    // MARK: - Functions

    private func deleteStudy() {
        withAnimation {
            context.delete(study)
        }
    }
}
