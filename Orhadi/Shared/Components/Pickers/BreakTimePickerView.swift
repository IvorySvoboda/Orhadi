//
//  BreakTimePickerView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 25/04/25.
//

import SwiftUI

struct BreakTimePickerView: View {
    @Environment(Settings.self) private var settings

    var body: some View {
        NavigationLink {
            BreakTimePicker()
        } label: {
            HStack {
                Text("Break Time")
                Spacer()
                Text(settings.breakTime.durationString())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct BreakTimePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

    var body: some View {
        List {
            Section {
                ForEach(1..<7) { index in
                    Button {
                        settings.breakTime = TimeInterval(300 * index)
                        dismiss()
                    } label: {
                        HStack {
                            Text("\(5 * index)min")
                            Spacer()
                            if settings.breakTime == TimeInterval(300 * index) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }.tint(Color.font)
                }
            }
        }
        .orhadiListStyle()
        .navigationTitle("Break Time")
        .navigationBarTitleDisplayMode(.inline)
    }
}
