//
//  ToDoPriorityPickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/04/25.
//

import SwiftUI

struct PriorityPickerView: View {

    @Binding var priority: Priority

    // MARK: - Views

    var body: some View {
        NavigationLink {
            PriorityPicker(priority: $priority)
        } label: {
            HStack {
                Label("Prioridade", systemImage: "exclamationmark.3")
                Spacer()
                Text(priority.priorityString)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PriorityPicker: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var priority: Priority

    var body: some View {
        List {
            Section {
                ForEach(Priority.allCases, id: \.self) { priority in
                    if priority != .none {
                        Button {
                            withAnimation(.smooth(duration: 0.1)) {
                                self.priority = priority
                            }
                            dismiss()
                        } label: {
                            HStack {
                                Text(priority.priorityString)
                                Spacer()
                                if self.priority == priority {
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
                        self.priority = .none
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text("Nenhuma")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        if self.priority == .none {
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
