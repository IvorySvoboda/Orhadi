//
//  GroupedSubjectsList.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/04/25.
//

import SwiftUI

struct GroupedSubjectsList<Subject: Identifiable, Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var scrollOffsetY: Int
    @Binding var selectedDay: Int

    let subjects: [Subject]
    let dateExtractor: (Subject) -> Date
    let cell: (Subject) -> Content

    var body: some View {
        VStack(spacing: 0) {
            WeekdayPickerBar(
                selectedDay: $selectedDay
            )
            .frame(height: 40)
            .padding(.horizontal)
        }
        .listRowInsets(
            EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.frame(in: .global).minY) { _, newY in
                        withAnimation(.smooth(duration: 0.25)) {
                            scrollOffsetY = Int(newY)
                        }
                    }
            }
        )

        let filteredSubjects = subjects.filter {
            Calendar.current.component(.weekday, from: dateExtractor($0)) == selectedDay
        }

        ForEach(filteredSubjects) { subject in
            cell(subject)
        }
    }
}

struct WeekdayPickerBar: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var selectedDay: Int

    @State private var isPressed: Int = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 12) {
                    ForEach(1...7, id: \.self) { index in
                        let name = Calendar.current.weekdaySymbols[index - 1]
                        let isSelected = index == selectedDay

                        Text(isSelected ? name.capitalized : name.prefix(3).capitalized)
                            .font(.callout)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule()
                                    .fill(
                                        isSelected
                                        ? LinearGradient(colors: [.accentColor, .accentColor.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                                        : LinearGradient(colors: [OrhadiTheme.getSecondaryBGColor(for: colorScheme), OrhadiTheme.getSecondaryBGColor(for: colorScheme)], startPoint: .top, endPoint: .bottom)
                                    )
                                    .background(
                                        Capsule()
                                            .fill(isSelected ? OrhadiTheme.getBGColor(for: .dark) : Color.clear)
                                    )
                            )
                            .foregroundColor(
                                isSelected
                                    ? OrhadiTheme.getBGColor(for: colorScheme)
                                    : .primary
                            )
                            .scaleEffect(isPressed == index ? 1.05 : 1)
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.75)) {
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                    selectedDay = index
                                    proxy.scrollTo(index, anchor: .center)
                                }
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
                            .id(index)
                    }
                }
                .onAppear {
                    withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.75)) {
                        proxy.scrollTo(selectedDay, anchor: .center)
                    }
                }
            }
        }
    }
}
