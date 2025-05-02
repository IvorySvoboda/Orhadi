//
//  WeekdayPickerBar.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/04/25.
//

import SwiftUI

struct WeekdayPickerBar: View {

    @Binding var selectedDay: Int

    @State private var isPressed: Int = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 12) {
                    ForEach(1...7, id: \.self) { index in
                        let name = Calendar.current.weekdaySymbols[index - 1]
                        let isSelected = index == selectedDay

                        ZStack {
                            Text(isSelected ? name.capitalized : name.prefix(3).capitalized)
                                .font(.callout)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .foregroundColor(isSelected ? Color.orhadiBG : .primary)
                        }
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.accentColor : Color.orhadiSecondaryBG)
                        )
                        .scaleEffect(isPressed == index ? 1.05 : 1)
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.75)) {
                                selectedDay = index
                                proxy.scrollTo(index, anchor: .center)
                            }
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.6)) {
                                        isPressed = index
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                                        isPressed = 0
                                    }
                                }
                        )
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0.8)
                                .blur(radius: phase.isIdentity ? 0 : 1)
                                .scaleEffect(phase.isIdentity ? 1 : 0.95)
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal)
                .frame(height: 40)
                .onAppear {
                    withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.75)) {
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
