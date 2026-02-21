//
//  ThemePickerView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import SwiftUI

struct ThemePicker: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    var body: some View {
        Picker(selection: Binding(
            get: { settings.theme },
            set: { settings.theme = $0 }
        )) {
            ForEach(Theme.allCases, id: \.self) { theme in
                Text(theme.name).tag(theme.hashValue)
            }
        } label: {
            HStack {
                ThemeIconView()
                Text("Theme")
            }
        }
        .pickerStyle(.navigationLink)
        .onChange(of: settings.theme) { _, _ in
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct ThemeIconView: View {
    var body: some View {
        ZStack {
            Image(systemName: "circle.righthalf.filled")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundStyle(Color.accentColor)
            Image(systemName: "circle.lefthalf.filled")
                .resizable()
                .frame(width: 13, height: 13)
                .foregroundStyle(Color.accentColor)
                .background {
                    Color.orhadiSecondaryBG
                        .frame(width: 12, height: 12)
                        .clipShape(Circle())
                }
        }
        .padding(.trailing, 10)
    }
}
