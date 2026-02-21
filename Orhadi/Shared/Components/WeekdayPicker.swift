//
//  WeekdayPicker.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 31/10/25.
//

import SwiftUI

struct WeekdayPicker: View {
    @Binding var selection: Date

    var body: some View {
        Picker("Weekday", selection: Binding(
            get: { Calendar.current.component(.weekday, from: selection) },
            set: { newWeekday in
                if let newDate = Calendar.current.nextDate(
                    after: selection,
                    matching: DateComponents(weekday: newWeekday),
                    matchingPolicy: .nextTimePreservingSmallerComponents
                ) {
                    selection = newDate
                }
            })
        ) {
            ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, name in
                Text(name.capitalized).tag(index + 1)
            }
        }.pickerStyle(.navigationLink)
    }
}
