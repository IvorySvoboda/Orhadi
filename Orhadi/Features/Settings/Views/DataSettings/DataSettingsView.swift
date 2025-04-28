//
//  DataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 02/04/25.
//

import SwiftData
import SwiftUI

struct DataSettingsView: View {

    @State private var viewModel = DataSettingsViewModel()

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
                    viewModel.showEraseDataAlert.toggle()
                }.tint(.red)
                .alert(
                    "Apagar todos os dados?",
                    isPresented: $viewModel.showEraseDataAlert
                ) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        viewModel.eraseAllData()
                    }
                } message: {
                    Text("Esta ação é permanente e não pode ser desfeita. Tem certeza que deseja continuar?")
                }
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Dados")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("DataSettingsView") {
    NavigationStack {
        DataSettingsView()
    }
}
