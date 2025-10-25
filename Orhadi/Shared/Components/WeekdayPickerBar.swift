//
//  WeekdayPickerBar.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/04/25.
//

import SwiftUI

struct WeekdayPickerBar: View {

    @Binding var selectedDay: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 12) {
                    ForEach(1...7, id: \.self) { index in
                        let name = Calendar.current.weekdaySymbols[index - 1]
                        let isSelected = index == selectedDay

                        Button {
                            withAnimation(.interactiveSpring(response: 0.75, dampingFraction: 0.75)) {
                                selectedDay = index
                                proxy.scrollTo(index, anchor: .center)
                            }
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                        } label: {
                            Text(isSelected ? name.capitalized : name.prefix(3).capitalized)
                                .font(.callout)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .foregroundColor(isSelected ? Color.orhadiBG : .primary)
                                .background {
                                    Capsule()
                                        .fill(isSelected ? Color.accentColor : Color.orhadiSecondaryBG)
                                }
                        }
                        .buttonStyle(TruePlainButtonStyle())
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0.5)
                                .blur(radius: phase.isIdentity ? 0 : 2)
                                .scaleEffect(phase.isIdentity ? 1 : 0.85)
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal)
                .frame(height: 44)
                .onAppear {
                    withAnimation(.interactiveSpring(response: 0.75, dampingFraction: 0.75)) {
                        proxy.scrollTo(selectedDay, anchor: .center)
                    }
                }
            }
        }
        .listRowInsets(
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
