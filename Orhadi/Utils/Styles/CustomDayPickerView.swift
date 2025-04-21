//
//  CustomDayPickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 20/04/25.
//

import SwiftUI

struct CustomDayPickerView: View {
    @Binding var date: Date

    // MARK: - Views

    var body: some View {
        NavigationLink {
            CustomDayPicker(date: $date)
        } label: {
            HStack {
                Text("Dia")
                Spacer()
                Text(Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1].capitalized)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct CustomDayPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme

    @State private var selectedWeekday: Int
    @Binding var date: Date

    init(date: Binding<Date>) {
        _date = date
        _selectedWeekday = State(initialValue: Calendar.current.component(.weekday, from: date.wrappedValue))
    }

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
            .listRowBackground(theme.secondaryBGColor())
            .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                if let newDate = Calendar.current.date(
                    byAdding: .day,
                    value: newWeekday - oldWeekday,
                    to: date
                ) {
                    date = newDate
                }
            }
        }
        .modifier(DefaultList())
        .navigationTitle("Dia")
        .navigationBarTitleDisplayMode(.inline)
    }
}
