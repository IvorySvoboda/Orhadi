//
//  ToDosSectionPickerBar.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 30/04/25.
//

import SwiftUI

struct ToDosSectionPickerBar: View {

    @Binding var selectedSection: ToDoSection

    var body: some View {
        HStack(spacing: 12) {
            ForEach(ToDoSection.allCases, id: \.self) { section in
                Button {
                    withAnimation {
                        selectedSection = section
                    }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    Text(section.string)
                        .font(.callout)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(selectedSection == section ? Color.orhadiBG : .primary)
                        .frame(maxWidth: .infinity)
                        .background {
                            Capsule()
                                .fill(selectedSection == section ? Color.accentColor : Color.orhadiSecondaryBG)
                        }
                }
                .buttonStyle(TruePlainButtonStyle())
                .frame(maxWidth: .infinity)
                .id(section)
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
        .listRowInsets(
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
