//
//  GracePeriodPickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 25/04/25.
//

import SwiftUI

struct GracePeriodPickerView: View {
    @Environment(Settings.self) private var settings

    var body: some View {
        NavigationLink {
            GracePeriodPicker()
        } label: {
            HStack {
                Text("Tolerância")
                Spacer()
                Text(formatTimeInterval(settings.gracePeriod))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct GracePeriodPicker: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings
    @Environment(OrhadiTheme.self) private var theme

    var body: some View {
        List {
            Section {
                ForEach(1..<5) { i in
                    Button {
                        settings.gracePeriod = TimeInterval(21600 * i)
                        dismiss()
                    } label: {
                        HStack {
                            Text(formatTimeInterval(TimeInterval(21600 * i)))
                            Spacer()
                            if settings.gracePeriod == TimeInterval(21600 * i) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }.tint(colorScheme == .dark ? .white : .black)
                }
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button {
                    settings.gracePeriod = 0
                    dismiss()
                } label: {
                    HStack {
                        Text("Sem Tolerância")
                            .foregroundStyle(.secondary)
                        Spacer()
                        if settings.gracePeriod == 0 {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(Color.secondary)
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Tolerância")
        .navigationBarTitleDisplayMode(.inline)
    }
}
