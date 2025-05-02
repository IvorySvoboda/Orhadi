//
//  ToDoPriorityPickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/04/25.
//

import SwiftUI

struct ToDoPriorityPickerView: View {

    @Bindable var todo: ToDo

    // MARK: - Views

    var body: some View {
        NavigationLink {
            ToDoPriorityPicker(todo: todo)
        } label: {
            HStack {
                Label("Prioridade", systemImage: "exclamationmark.3")
                Spacer()
                Text(todo.priority.priorityString)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ToDoPriorityPicker: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var todo: ToDo

    var body: some View {
        List {
            Section {
                ForEach(Priority.allCases, id: \.self) { priority in
                    if priority != .none {
                        Button {
                            withAnimation(.smooth(duration: 0.1)) {
                                todo.priority = priority
                            }
                            dismiss()
                        } label: {
                            HStack {
                                Text(priority.priorityString)
                                Spacer()
                                if todo.priority == priority {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .tint(.font)
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button {
                    withAnimation(.smooth(duration: 0.1)) {
                        todo.priority = .none
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text("Nenhuma")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        if todo.priority == .none {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(.font)
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Prioridade")
        .navigationBarTitleDisplayMode(.inline)
    }
}

