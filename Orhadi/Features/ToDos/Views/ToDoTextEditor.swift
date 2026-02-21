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
    @State private var showAddLinkSheet = false
    @State private var selection = AttributedTextSelection()
    @FocusState private var isFocused: Bool

    @Binding var text: AttributedString

    // MARK: - Computed Properties

    private var attributes: AttributeContainer {
        selection.typingAttributes(in: text)
    }

    private var isBold: Bool {
        guard let font = attributes.font else {
            let resolvedDefaultFont = Font.default.resolve(in: fontResolutionContext)
            return resolvedDefaultFont.isBold
        }

        let resolved = font.resolve(in: fontResolutionContext)
        return resolved.isBold
    }

    private var isItalic: Bool {
        guard let font = attributes.font else {
            let resolvedDefaultFont = Font.default.resolve(in: fontResolutionContext)
            return resolvedDefaultFont.isItalic
        }

        let resolved = font.resolve(in: fontResolutionContext)
        return resolved.isItalic
    }

    private var isUnderline: Bool {
        attributes.underlineStyle == .single
    }

    private var isStrikethrough: Bool {
        attributes.strikethroughStyle == .single
    }

    private var isHighlighted: Bool {
        attributes.backgroundColor == .accentColor.opacity(0.25)
    }

    // MARK: - Views

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .frame(height: 300)
            .focused($isFocused)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isFocused {
                        ZStack {
                            HStack(spacing: 40) {
                                toolBarButton("Bold", systemImage: "bold", isActive: isBold) {
                                    text.transformAttributes(in: &selection) { container in
                                        let currentFont = container.font ?? .default
                                        let resolved = currentFont.resolve(in: fontResolutionContext)
                                        container.font = currentFont.bold(!resolved.isBold)
                                    }
                                }

                                toolBarButton("Italic", systemImage: "italic", isActive: isItalic) {
                                    text.transformAttributes(in: &selection) { container in
                                        let currentFont = container.font ?? .default
                                        let resolved = currentFont.resolve(in: fontResolutionContext)
                                        container.font = currentFont.italic(!resolved.isItalic)
                                    }
                                }

                                toolBarButton("Underline", systemImage: "underline", isActive: isUnderline) {
                                    text.transformAttributes(in: &selection) { container in
                                        if container.underlineStyle == .single {
                                            container.underlineStyle = .none
                                        } else {
                                            container.underlineStyle = .single
                                        }
                                    }
                                }

                                toolBarButton("Strikethrough", systemImage: "strikethrough", isActive: isStrikethrough) {
                                    text.transformAttributes(in: &selection) { container in
                                        if container.strikethroughStyle == .single {
                                            container.strikethroughStyle = .none
                                        } else {
                                            container.strikethroughStyle = .single
                                        }
                                    }
                                }

                                toolBarButton("Highlight", systemImage: "highlighter", isActive: isHighlighted) {
                                    text.transformAttributes(in: &selection) { container in
                                        if isHighlighted {
                                            container.backgroundColor = .clear
                                            container.foregroundColor = .font
                                        } else {
                                            container.backgroundColor = .accentColor.opacity(0.25)
                                            container.foregroundColor = .cyan
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 50)
                            .glassEffect(.regular.interactive())
                        }.offset(y: -10)
                    }
                }.sharedBackgroundVisibility(.hidden)
            }
    }

    private func toolBarButton(
        _ label: LocalizedStringKey,
        systemImage: String,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(label, systemImage: systemImage) {
            action()
        }
        .labelStyle(.iconOnly)
        .frame(width: 30, height: 30)
        .background {
            if isActive {
                Circle()
                    .fill(Color.accentColor)
                    .opacity(0.75)
                    .frame(width: 40, height: 40)
            }
        }
    }
}
