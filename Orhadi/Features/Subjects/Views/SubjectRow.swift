//
//  SubjectRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/04/25.
//

import SwiftUI

struct SubjectRow: View {
    @Environment(SubjectsView.ViewModel.self) private var vm
    @Environment(Settings.self) private var settings

    let subject: Subject

    // MARK: - Body

    var body: some View {
        TimelineView(.everyMinute) { _ in
            HStack(spacing: 5) {
                ongoingIndicator

                if subject.isRecess {
                    intervalView
                } else {
                    subjectView
                }
            }
        }
        .swipeActions(edge: .leading) {
            sendEmailButton.tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            deleteButton
            duplicateButton.tint(.teal)
            editButton.tint(.accentColor)
        }
        .contextMenu {
            sendEmailButton
            editButton
            duplicateButton
            deleteButton
        }
    }

    // MARK: - Ongoing Indicator

    @ViewBuilder private var ongoingIndicator: some View {
        if subject.isOngoing && settings.showCurrentSubjectIndicator {
            RoundedRectangle(cornerRadius: 3, style: .circular)
                .fill(Color.cyan)
                .frame(width: 5)
                .frame(maxHeight: .infinity)
        }
    }

    // MARK: - Subject View

    private var subjectView: some View {
        VStack(alignment: .leading) {
            Text(subject.name)
                .titleStyle()

            VStack(alignment: .leading, spacing: 3) {
                if let teacher = subject.teacher {
                    if !teacher.name.isEmpty {
                        CustomLabel("\(teacher.name)", systemImage: "person.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if !teacher.email.isEmpty {
                        CustomLabel("\(teacher.email)", systemImage: "envelope.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                CustomLabel("\(subject.startTime.formatToHour()) – \(subject.endTime.formatToHour())", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !subject.place.isEmpty {
                    CustomLabel("\(subject.place)", systemImage: "building.2.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Interval View

    private var intervalView: some View {
        HStack {
            Text("Interval")
                .textCase(.uppercase)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
            CustomLabel("\(subject.startTime.formatToHour()) – \(subject.endTime.formatToHour())", systemImage: "clock.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder private var sendEmailButton: some View {
        if let teacher = subject.teacher, !teacher.email.isEmpty {
            Button("Send e-mail", systemImage: "envelope.fill") {
                subject.openMail()
            }
        }
    }

    private var editButton: some View {
        Button("Edit", systemImage: "pencil") {
            vm.subjectToEdit = subject
        }
    }

    private var duplicateButton: some View {
        Button("Duplicate", systemImage: "rectangle.fill.on.rectangle.angled.fill") {
            vm.subjectToAdd = subject
        }
    }

    private var deleteButton: some View {
        Button("Delete", systemImage: "trash.fill", role: .destructive) {
            try? vm.softDeleteSubject(subject)
        }
    }
}
