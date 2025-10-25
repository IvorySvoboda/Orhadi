//
//  PriorityPickerView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 28/04/25.
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
                Label("Priority", systemImage: "exclamationmark.3")
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
            }

            Section {
                Button {
                    withAnimation(.smooth(duration: 0.1)) {
                        self.priority = .none
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text(Priority.none.priorityString)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        if self.priority == .none {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(.font)
            }
        }
        .navigationTitle("Priority")
        .navigationBarTitleDisplayMode(.inline)
    }
}
