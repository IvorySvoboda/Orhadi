//
//  ToDosSectionPickerBar.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/04/25.
//

import SwiftUI

enum ToDoSection: CaseIterable {
    case pending, completed

    var string: String {
        switch self {
        case .pending: return String(localized: "Pendentes")
        case .completed: return String(localized: "Concluídas")
        }
    }
}

struct ToDosSectionPickerBar: View {

    @Binding var selectedSection: ToDoSection

    @State private var isPressed: ToDoSection?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(ToDoSection.allCases, id: \.string) { section in
                ZStack {
                    Text("\(section.string)")
                        .font(.callout)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(selectedSection == section ? Color.orhadiBG : .primary)
                }
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(selectedSection == section ? Color.accentColor : Color.orhadiSecondaryBG)
                )
                .scaleEffect(isPressed == section ? 1.05 : 1)
                .onTapGesture {
                    withAnimation {
                        selectedSection = section
                    }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation {
                                isPressed = section
                            }
                        }
                        .onEnded { _ in
                            withAnimation {
                                isPressed = nil
                            }
                        }
                )
                .id(section)
            }
        }
        .padding(.horizontal)
        .frame(height: 40)
        .listRowInsets(
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
