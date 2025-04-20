//
//  SubjectDayPickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 19/04/25.
//

import SwiftUI

struct SubjectDayPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @Binding var selectedWeekday: Int
    @Bindable var subject: Subject

    // MARK: - Views

    var body: some View {
        List {
            Section {
                ForEach(1...7, id: \.self) { index in
                    let name = Calendar.current.weekdaySymbols[index - 1].capitalized

                    Button {
                        selectedWeekday = index
                        dismiss()
                    } label: {
                        HStack {
                            Text(name)
                                .font(.headline)
                            Spacer()
                            if selectedWeekday == index {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }.tint(colorScheme == .dark ? .white : .black)
                }
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                if let newDate = Calendar.current.date(
                    byAdding: .day,
                    value: newWeekday - oldWeekday,
                    to: subject.schedule
                ) {
                    subject.schedule = newDate
                }
            }
        }
        .navigationTitle("Dia")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(OrhadiTheme.getBGColor(for: colorScheme))
    }
}

