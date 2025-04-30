//
//  ToDoPriorityPickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/04/25.
//

import SwiftUI

enum Priority: Int, Codable, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    var priorityString: String {
        switch self {
        case .none:
            return String(localized: "Nenhuma")
        case .low:
            return String(localized: "Baixa")
        case .medium:
            return String(localized: "Média")
        case .high:
            return String(localized: "Alta")
        }
    }
}

extension Priority: Comparable {
    static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

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
    @Environment(\.colorScheme) private var colorScheme

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
                        .tint(colorScheme == .dark ? .white : .black)
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
                }.tint(colorScheme == .dark ? .white : .black)
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Prioridade")
        .navigationBarTitleDisplayMode(.inline)
    }
}

