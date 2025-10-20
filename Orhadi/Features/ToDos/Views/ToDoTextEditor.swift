//
//  ToDoTextEditor.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 20/10/25.
//

import SwiftUI

@available(iOS 26, *)
struct ToDoTextEditor: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.fontResolutionContext) var fontResolutionContext

    @Binding var text: AttributedString
    @State var selection = AttributedTextSelection()

    // MARK: - Computed Helpers

    private var isBold: Bool {
        let attributes = selection.typingAttributes(in: text)

        if let font = attributes.font {
            let resolved = font.resolve(in: fontResolutionContext)
            return resolved.isBold
        }

        let resolvedDefaultFont = Font.default.resolve(in: fontResolutionContext)
        return resolvedDefaultFont.isBold
    }

    private var isItalic: Bool {
        let attributes = selection.typingAttributes(in: text)

        if let font = attributes.font {
            let resolved = font.resolve(in: fontResolutionContext)
            return resolved.isItalic
        }

        let resolvedDefaultFont = Font.default.resolve(in: fontResolutionContext)
        return resolvedDefaultFont.isItalic
    }

    private var isUnderline: Bool {
        let attributes = selection.typingAttributes(in: text)

        if attributes.underlineStyle == .single {
            return true
        } else {
            return false
        }
    }

    private var isStrikethrough: Bool {
        let attributes = selection.typingAttributes(in: text)

        if attributes.strikethroughStyle == .single {
            return true
        } else {
            return false
        }
    }

    private var isMarked: Bool {
        let attributes = selection.typingAttributes(in: text)

        if attributes.backgroundColor == .accentColor.opacity(0.25) {
            return true
        } else {
            return false
        }
    }

    // MAKR: - Views

    var body: some View {
        ZStack {
            VStack {
                if text.characters.isEmpty {
                    Text("Do …")
                        .foregroundStyle(Color.secondary)
                        .opacity(0.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 10)
            .padding(.leading, 5)

            TextEditor(text: $text, selection: $selection)
                .frame(height: 200)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                            HStack(spacing: 30) {
                                Button("Bold", systemImage: "bold") {
                                    text.transformAttributes(in: &selection) { container in
                                        let currentFont = container.font ?? .default
                                        let resolved = currentFont.resolve(in: fontResolutionContext)
                                        container.font = currentFont.bold(!resolved.isBold)
                                    }
                                }
                                .labelStyle(.iconOnly)
                                .background {
                                    if isBold {
                                        Circle()
                                            .fill(Color.accentColor)
                                            .opacity(0.75)
                                            .frame(width: 40, height: 40)
                                    }
                                }

                                Button("Italic", systemImage: "italic") {
                                    text.transformAttributes(in: &selection) { container in
                                        let currentFont = container.font ?? .default
                                        let resolved = currentFont.resolve(in: fontResolutionContext)
                                        container.font = currentFont.italic(!resolved.isItalic)
                                    }
                                }
                                .labelStyle(.iconOnly)
                                .background {
                                    if isItalic {
                                        Circle()
                                            .fill(Color.accentColor)
                                            .opacity(0.75)
                                            .frame(width: 40, height: 40)
                                    }
                                }

                                Button("Underline", systemImage: "underline") {
                                    text.transformAttributes(in: &selection) { container in
                                        if container.underlineStyle == .single {
                                            container.underlineStyle = .none
                                        } else {
                                            container.underlineStyle = .single
                                        }
                                    }
                                }
                                .labelStyle(.iconOnly)
                                .background {
                                    if isUnderline {
                                        Circle()
                                            .fill(Color.accentColor)
                                            .opacity(0.75)
                                            .frame(width: 40, height: 40)
                                    }
                                }

                                Button("Strikethrough", systemImage: "strikethrough") {
                                    text.transformAttributes(in: &selection) { container in
                                        if container.strikethroughStyle == .single {
                                            container.strikethroughStyle = .none
                                        } else {
                                            container.strikethroughStyle = .single
                                        }
                                    }
                                }
                                .labelStyle(.iconOnly)
                                .background {
                                    if isStrikethrough {
                                        Circle()
                                            .fill(Color.accentColor)
                                            .opacity(0.75)
                                            .frame(width: 40, height: 40)
                                    }
                                }

                                Button("Highlight", systemImage: "highlighter") {
                                    text.transformAttributes(in: &selection) { container in
                                        if isMarked {
                                            container.backgroundColor = .clear
                                            container.foregroundColor = .white
                                        } else {
                                            container.backgroundColor = .accentColor.opacity(0.25)
                                            container.foregroundColor = .cyan
                                        }
                                    }
                                }
                                .labelStyle(.iconOnly)
                                .background {
                                    if isMarked {
                                        Circle()
                                            .fill(Color.accentColor)
                                            .opacity(0.75)
                                            .frame(width: 40, height: 40)
                                    }
                                }

//                                Button("Add Link", systemImage: "link") {
//                                    text.transformAttributes(in: &selection) { container in
//                                        container.link = URL(string: "https://github.com")
//                                    }
//                                }
                            }.padding(.horizontal, 5)
                    }
                }
        }
    }
}
