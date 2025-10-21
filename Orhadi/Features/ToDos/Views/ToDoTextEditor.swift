//
//  ToDoTextEditor.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 20/10/25.
//

import SwiftUI

@available(iOS 26, *)
struct ToDoTextEditor: View {
    @Environment(\.fontResolutionContext) private var fontResolutionContext

    @Binding var text: AttributedString

    @State private var showAddLinkSheet = false
    @State private var selection = AttributedTextSelection()
    @FocusState private var isFocused: Bool

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

    private var isList: Bool {
        let prefix = AttributedString("• ")

        guard case .insertionPoint(let idx) = selection.indices(in: text) else { return false }

        let lr = text.lineRange(containing: idx)
        let line = text[lr]

        return line.characters.starts(with: prefix.characters)
    }

    // MAKR: - Views

    var body: some View {
        ZStack {
            if text.characters.isEmpty {
                Text("Do …")
                    .foregroundStyle(Color.secondary)
                    .opacity(0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 10)
                    .padding(.leading, 5)
            }

            TextEditor(text: $text, selection: $selection)
                .frame(height: 200)
                .focused($isFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if isFocused {
                            ZStack {
                                HStack(spacing: 30) {
                                    Button("Bold", systemImage: "bold") {
                                        text.transformAttributes(in: &selection) { container in
                                            let currentFont = container.font ?? .default
                                            let resolved = currentFont.resolve(in: fontResolutionContext)
                                            container.font = currentFont.bold(!resolved.isBold)
                                        }
                                    }
                                    .labelStyle(.iconOnly)
                                    .frame(width: 30, height: 30)
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
                                    .frame(width: 30, height: 30)
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
                                    .frame(width: 30, height: 30)
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
                                    .frame(width: 30, height: 30)
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
                                                container.foregroundColor = .font
                                            } else {
                                                container.backgroundColor = .accentColor.opacity(0.25)
                                                container.foregroundColor = .cyan
                                            }
                                        }
                                    }
                                    .labelStyle(.iconOnly)
                                    .frame(width: 30, height: 30)
                                    .background {
                                        if isMarked {
                                            Circle()
                                                .fill(Color.accentColor)
                                                .opacity(0.75)
                                                .frame(width: 40, height: 40)
                                        }
                                    }

                                    Button("List", systemImage: "list.bullet") {
                                        let prefix = AttributedString("• ")
                                        text.transform(updating: &selection) { str in
                                            let indices = selection.indices(in: str)
                                            guard case .insertionPoint(let idx) = indices else { return }

                                            let lr = str.lineRange(containing: idx)
                                            let line = str[lr]

                                            if line.characters.starts(with: prefix.characters) {
                                                let prefixEnd = str.index(lr.lowerBound, offsetByCharacters: prefix.characters.count)
                                                str.removeSubrange(lr.lowerBound..<prefixEnd)
                                            } else {
                                                str.insert(prefix, at: lr.lowerBound)
                                            }
                                        }
                                    }
                                    .labelStyle(.iconOnly)
                                    .frame(width: 30, height: 30)
                                    .background {
                                        if isList {
                                            Circle()
                                                .fill(Color.accentColor)
                                                .opacity(0.75)
                                                .frame(width: 40, height: 40)
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .frame(height: 50)
                                .glassEffect(.regular.interactive())
                            }
                            .offset(y: -10)
                        }
                    }.sharedBackgroundVisibility(.hidden)
                }
        }
    }
}

#Preview {
    if #available(iOS 26, *) {
        ToDoTextEditor(text: Binding(get: { AttributedString() }, set: { _ = $0 }))
    } else {
        EmptyView()
    }
}
