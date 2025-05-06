//
//  RollingTextView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 21/04/25.
//

import SwiftUI

struct RollingTextView: View {
    var text: String

    @State private var previousText: String = ""
    @State private var isAnimating = false
    @State private var pendingText: String?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<max(previousText.count, text.count), id: \.self) { index in
                let oldChar = character(at: index, in: previousText)
                let newChar = character(at: index, in: text)
                RollingCharView(from: oldChar, to: newChar, shouldAnimate: oldChar != newChar && isAnimating)
            }
        }
        .onChange(of: text) { _, newText in
            if newText != previousText {
                if isAnimating {
                    pendingText = newText
                } else {
                    startAnimation(with: newText)
                }
            }
        }
        .onAppear {
            previousText = text
        }
    }

    private func startAnimation(with newText: String) {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            previousText = newText
            isAnimating = false

            if let nextText = pendingText {
                pendingText = nil
                startAnimation(with: nextText)
            }
        }
    }

    private func character(at index: Int, in string: String) -> String {
        if index < string.count {
            let charIndex = string.index(string.startIndex, offsetBy: index)
            return String(string[charIndex])
        }
        return " "
    }
}

struct RollingCharView: View {
    var from: String
    var to: String
    var shouldAnimate: Bool

    @State private var animating = false

    var body: some View {
        ZStack {
            Text(from)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .offset(y: animating ? -40 : 0)
                .opacity(animating ? 0 : 1)
                .blur(radius: animating ? 10 : 0)
                .scaleEffect(animating ? 0.4 : 1)

            Text(to)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .offset(y: animating ? 0 : 40)
                .opacity(animating ? 1 : 0)
                .blur(radius: animating ? 0 : 10)
                .scaleEffect(animating ? 1 : 0.4)
        }
        .frame(width: 24, height: 50)
        .onChange(of: shouldAnimate) { _, newValue in
            if newValue {
                withAnimation(.bouncy(duration: 0.3)) {
                    animating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animating = false
                }
            }
        }
    }
}
