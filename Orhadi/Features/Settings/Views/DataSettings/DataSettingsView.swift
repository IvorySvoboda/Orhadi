//
//  DataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 02/04/25.
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
                    Label("Subjects", systemImage: "book.fill")
                }
                NavigationLink {
                    ToDosDataSettingsView()
                } label: {
                    Label("To-Dos", systemImage: "list.clipboard.fill")
                }
                NavigationLink {
                    SRDataSettingsView()
                } label: {
                    Label("Study Routine", systemImage: "graduationcap.fill")
                }
            }

            Section {
                Button("Reset all data") {
                    showEraseDataAlert.toggle()
                }.tint(.red)
                .alert(
                    "Reset all data?",
                    isPresented: $showEraseDataAlert
                ) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) {
                        eraseAllData()
                    }
                } message: {
                    Text("All data, including subjects, to-dos, and studies, will be deleted. It will not be possible to recover the data after resetting. Are you sure you want to continue?")
                }
            }
        }
        .orhadiListStyle()
        .navigationTitle("Data")
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
                let settings = try context.fetch(FetchDescriptor<Settings>())

                for teacher in teachers { context.delete(teacher) }
                for subject in subjects { context.delete(subject) }
                for todo in todos { context.delete(todo) }
                for study in studies { context.delete(study) }
                for setting in settings { context.delete(setting) }

                context.insert(Settings())

                try context.save()

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
