//
//  SubjectsAddOptionsSheet.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 30/10/25.
//

import SwiftUI

extension SubjectsView {
    struct SubjectsAddOptionsSheet: View {
        @Environment(\.dismiss) private var dismiss

        @Binding var subjectToAdd: Subject?
        var selectedDay: Int

        private var schedule: Date {
            Calendar.current.date(
                bySetting: .weekday,
                value: selectedDay,
                of: Date(timeIntervalSince1970: 0)
            ) ?? .now
        }

        var body: some View {
            ZStack {
                VStack(spacing: 10) {
                    ForEach([
                        (title: String(localized: "Add Subject"), isRecess: false),
                        (title: String(localized: "Add Interval"), isRecess: true)
                    ], id: \.title) { option in
                        Button {
                            subjectToAdd = Subject(schedule: schedule, isRecess: option.isRecess)
                            dismiss()
                        } label: {
                            if #available(iOS 26, *) {
                                Capsule()
                                    .fill(Color.accentColor)
                                    .frame(maxWidth: .infinity, minHeight: 45)
                                    .overlay {
                                        buttonText(text: option.title)
                                    }
                            } else {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .fill(Color.accentColor)
                                    .frame(maxWidth: .infinity, minHeight: 45)
                                    .overlay {
                                        buttonText(text: option.title)
                                    }
                            }
                        }
                    }
                }.offset(y: 15)
            }
            .presentationDetents([.height(110)])
            .padding()
        }

        private func buttonText(text: String) -> some View {
            Text(text)
                .textCase(.uppercase)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.orhadiSecondaryForeground)
        }
    }
}
