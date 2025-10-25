//
//  TeacherRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI

struct TeacherRowView: View {
    @Environment(\.modelContext) private var context

    var teacher: Teacher
    var onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(teacher.name)
                .font(.headline)
            if !teacher.email.isEmpty {
                CustomLabel("\(teacher.email)", systemImage: "envelope.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .swipeActions(edge: .leading) {
            if !teacher.email.isEmpty {
                Button("Send e-mail", systemImage: "envelope.fill") {
                    teacher.openMail()
                }.tint(.accentColor)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                try? teacher.hardDelete(in: context)
            }

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }.tint(.accentColor)
        }
        .contextMenu {
            if !teacher.email.isEmpty {
                Button("Send e-mail", systemImage: "envelope.fill") {
                    teacher.openMail()
                }
            }

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }

            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                try? teacher.hardDelete(in: context)
            }
        }
    }
}
