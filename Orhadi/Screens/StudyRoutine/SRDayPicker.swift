//
//  SRDayPicker.swift
//  Orhadi
//
//  Created by Zyvoxi . on 19/04/25.
//

import SwiftData
import SwiftUI

protocol SRDayPicker: Identifiable {
    var studyDay: Date { get set }
}

extension Subject: SRDayPicker {}
extension SRSubject: SRDayPicker {}

struct SRDayPickerView<Subject: SRDayPicker>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @Binding var selectedWeekday: Int
    @Binding var subject: Subject

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
                    to: subject.studyDay
                ) {
                    subject.studyDay = newDate
                }
            }
        }
        .navigationTitle("Dia")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(OrhadiTheme.getBGColor(for: colorScheme))
    }
}
